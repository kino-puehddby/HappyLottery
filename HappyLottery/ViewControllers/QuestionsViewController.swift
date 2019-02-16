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
    @IBOutlet weak private var nameValidLabel: UILabel!
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
    }
    
    private let name = BehaviorRelay<String>(value: "")
    private let economyGrade = BehaviorRelay<EconomyGrade>(value: .good)
    private let effortGrade = BehaviorRelay<EffortGrade>(value: .fair)
    private let schoolStage = BehaviorRelay<SchoolStage>(value: .preschool)
    private let calculated = BehaviorRelay<Double>(value: 0)
    
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
            case .juniorHighSchool: return 1000
            case .highSchool: return 2000
            case .university: return 3000
            }
        }
        
        var max: Double {
            switch self {
            case .preschool: return 500
            case .elementarySchool: return 2000
            case .juniorHighSchool: return 3000
            case .highSchool: return 8000
            case .university: return 17000
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
        
        calculateButton.backgroundColor = .lightGray
        
        bind()
    }
    
    func bind() {
        let nameValid = nameTextField.rx.text
            .map { $0 != "" }
            .share(replay: 1)
        nameValid
            .bind(to: calculateButton.rx.isEnabled)
            .disposed(by: disposeBag)
        nameValid
            .bind(to: nameValidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        nameValid
            .map { $0 ? Asset.systemBlue.color : .lightGray }
            .subscribe(onNext: { [unowned self] color in
                self.calculateButton.backgroundColor = color
            })
            .disposed(by: disposeBag)
        
        nameTextField.rx.text.orEmpty
            .bind(to: name)
            .disposed(by: disposeBag)
        
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
        
        calculateButton.rx.tap
            .map { [unowned self] in
                self.calculate(
                    economyRate: self.economyGrade.value.rate,
                    effortRate: self.effortGrade.value.rate,
                    min: self.schoolStage.value.min,
                    max: self.schoolStage.value.max
                )
            }
            .bind(to: calculated)
            .disposed(by: disposeBag)
        
        calculated.asDriver()
            .skip(1)
            .drive(onNext: { [unowned self] _ in
                self.perform(segue: StoryboardSegue.Questions.showResult)
            })
            .disposed(by: disposeBag)
    }
    
    func calculate(economyRate: Double, effortRate: Double, min: Double, max: Double) -> Double {
        // economyをmax、minに反映させる
        let fixedMax = max * economyRate
        let fixedMin = min * economyRate
        
        let result: Double = {
            let random = Double.random(in: 1...100)
            // effortを確立に反映させる
            let great: Double = Question.StandardProbability.great * effortRate
            let good: Double = Question.StandardProbability.good * effortRate
            let bad: Double = Question.StandardProbability.bad * (1 / effortRate)
            let shit: Double = Question.StandardProbability.shit * (1 / effortRate)
            let usually: Double = 100 - (great + good + bad + shit)
            let list = [great, good, usually, bad, shit]
            
            if random <= list[0] {
                // great
                return fixedMax
            } else if random <= (list[0] + list[1]) {
                // good
                return roundBySchoolStage(fixedMin + (fixedMax - fixedMin) / 1.5)
            } else if random <= (list[0] + list[1] + list[2]) {
                // usually
                return roundBySchoolStage(fixedMin + (fixedMax - fixedMin) / 2)
            } else if random <= (list[0] + list[1] + list[2] + list[3]) {
                // bad
                return roundBySchoolStage(fixedMin + (fixedMax - fixedMin) / 3)
            } else {
                // shit
                return fixedMin
            }
        }()
        
        debugPrint(result)
        return result
    }
    
    func roundBySchoolStage(_ value: Double) -> Double {
        switch schoolStage.value {
        case .preschool:
            return round(value / 100) * 100
        case .elementarySchool:
            return round(value / 500) * 500
        default:
            return round(value / 1000) * 1000
        }
    }
}

// -----------------------
// - Bubble Transition
// -----------------------

extension QuestionsViewController: UIViewControllerTransitioningDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Questions.showResult.rawValue {
            let vc = segue.destination as! ResultViewController
            vc.name = name.value
            vc.result = calculated.value
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
