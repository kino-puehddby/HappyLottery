//
//  QuestionsViewController.swift
//  HappyLottery
//
//  Created by 杉田 尚哉 on 2019/02/12.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import BubbleTransition

final class QuestionsViewController: UIViewController {

    @IBOutlet weak private var economyGradeSegCon: UISegmentedControl!
    @IBOutlet weak private var effortGradeSegCon: UISegmentedControl!
    @IBOutlet weak private var schoolStageSegCon: UISegmentedControl!
    @IBOutlet weak fileprivate var calculateButton: UIButton!
    @IBOutlet weak private var nameTextField: UITextField!
    
    private let economyGrade = BehaviorRelay<EconomyGrade>(value: .good)
    private let effortGrade = BehaviorRelay<EffortGrade>(value: .fair)
    private let schoolStage = BehaviorRelay<SchoolStage>(value: .preschool)
    private let name = BehaviorRelay<String>(value: "")
    
    private let disposeBag = DisposeBag()
    private let transition = BubbleTransition()
    private let interactiveTransition = BubbleInteractiveTransition()
    
    private enum EconomyGrade: CaseIterable {
        case good
        case fair
        case poor
        
        var rate: Double {
            switch self {
            case .good: return 1.2
            case .fair: return 1
            case .poor: return 0.8
            }
        }
    }
    
    private enum EffortGrade: CaseIterable {
        case good
        case fair
        case poor
        
        var rate: Double {
            switch self {
            case .good: return 1.2
            case .fair: return 1
            case .poor: return 0.8
            }
        }
    }
    
    private enum SchoolStage: CaseIterable {
        case preschool
        case elementarySchool
        case juniorHighSchool
        case highSchool
        case university
        
        var rate: Double {
            switch self {
            case .preschool: return 500
            case .elementarySchool: return 2000
            case .juniorHighSchool: return 5000
            case .highSchool: return 7000
            case .university: return 10000
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    func bind() {
        economyGradeSegCon.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .map { EconomyGrade.allCases[$0] }
            .bind(to: economyGrade)
            .disposed(by: disposeBag)
        
        effortGradeSegCon.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .map { EffortGrade.allCases[$0] }
            .bind(to: effortGrade)
            .disposed(by: disposeBag)
        
        schoolStageSegCon.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .map { SchoolStage.allCases[$0] }
            .bind(to: schoolStage)
            .disposed(by: disposeBag)
        
        nameTextField.rx.text.orEmpty
            .bind(to: name)
            .disposed(by: disposeBag)
        
        calculateButton.rx.tap
            .map { [unowned self] in
                (
                    economyRate: self.economyGrade.value.rate,
                    effortRate: self.effortGrade.value.rate,
                    schoolRate: self.schoolStage.value.rate
                )
            }
            .subscribe(onNext: { [unowned self] arg in
                self.calculate(
                    economyRate: arg.economyRate,
                    effortRate: arg.effortRate,
                    schoolRate: arg.schoolRate
                )
            })
            .disposed(by: disposeBag)
    }
    
    func calculate(economyRate: Double, effortRate: Double, schoolRate: Double) {
        // TODO: 計算処理
        perform(segue: StoryboardSegue.Questions.showResult)
    }
}

// -----------------------
// - Bubble Transition
// -----------------------

extension QuestionsViewController: UIViewControllerTransitioningDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Questions.showResult.rawValue {
            let vc = segue.destination as! ResultViewController
            vc.transitioningDelegate = self
            vc.modalPresentationStyle = .custom
            vc.interactiveTransition = interactiveTransition
            interactiveTransition.attach(to: vc)
        }
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = calculateButton.center
        transition.bubbleColor = calculateButton.backgroundColor ?? Asset.systemBlue.color
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = calculateButton.center
        transition.bubbleColor = calculateButton.backgroundColor ?? Asset.systemBlue.color
        return transition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
}
