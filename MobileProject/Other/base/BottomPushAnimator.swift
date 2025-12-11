//
//  BottomPushAnimator.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/7/26.
//

class BottomPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }

        let container = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)

        toVC.view.frame = finalFrame.offsetBy(dx: 0, dy: container.bounds.height)
        container.addSubview(toVC.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toVC.view.frame = finalFrame
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}
