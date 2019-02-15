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
            case .good: return 1.5
            case .fair: return 1
            case .poor: return 0.75
            }
        }
    }
    
    private enum EffortGrade: CaseIterable {
        case good
        case fair
        case poor
        
        var rate: Double {
            switch self {
            case .good: return 2
            case .fair: return 1
            case .poor: return 0.5
            }
        }
    }
    
    private enum SchoolStage: CaseIterable {
        case preschool
        case elementarySchool
        case juniorHighSchool
        case highSchool
        case university
        
        var min: Double {
            switch self {
            case .preschool: return 100
            case .elementarySchool: return 500
            case .juniorHighSchool: return 2000
            case .highSchool: return 3000
            case .university: return 5000
            }
        }
        
        var max: Double {
            switch self {
            case .preschool: return 1000
            case .elementarySchool: return 3000
            case .juniorHighSchool: return 8000
            case .highSchool: return 12000
            case .university: return 15000
            }
        }
    }
    
    enum Probability {
        case great
        case good
        case usually
        case bad
        case shit
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
                    min: self.schoolStage.value.min,
                    max: self.schoolStage.value.max
                )
            }
            .subscribe(onNext: { [unowned self] arg in
                self.calculate(
                    economyRate: arg.economyRate,
                    effortRate: arg.effortRate,
                    min: arg.min,
                    max: arg.max
                )
            })
            .disposed(by: disposeBag)
    }
    
    func calculate(economyRate: Double, effortRate: Double, min: Double, max: Double) {
        // probability = 確率が良かったかどうか（努力して景気がいいほど当たりやすくなる）
        let probability: Probability = {
            let count = Double.random(in: 1...100)
            if count <= 5 * economyRate * effortRate {
                return .great
            } else if count <= 25 * economyRate * effortRate {
                return .good
            } else if count <= 75 {
                return .usually
            } else if count <= 95 * (1 / economyRate) * (1 / effortRate)  {
                return .bad
            } else {
                return .shit
            }
        }()
        
        // 運が良かったらmaxが増える
        let fixMax: Double = {
            switch probability {
            case .great: return max * 1.5
            case .good: return max * 1.2
            case .usually: return max
            case .bad: return max * 0.8
            case .shit: return max * 0.5
            }
        }()
        let fixMin: Double = {
            switch probability {
            case .great: return min * 1.5
            case .good: return min * 1.2
            case .usually: return min
            case .bad: return min * 0.8
            case .shit: return min * 0.5
            }
        }()
        
        // random = 学校段階によってランダムなお年玉がランダムに決まる
        var random = Double.random(in: fixMin ... fixMax)
        switch schoolStage.value {
        case .preschool:
            random = round(random / 100) * 100
        case .elementarySchool:
            random = round(random / 500) * 500
        default:
            random = round(random / 1000) * 1000
        }
        
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
