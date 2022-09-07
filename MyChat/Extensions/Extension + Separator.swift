//
//  Extension + Separator.swift
//  MyChat
//
//  Created by Zaur on 24.08.2022.
//

import UIKit

extension UIView {

    static func horizontalSeparator(_ color: UIColor = .lightGray,
                                    height: CGFloat = 1 / UIScreen.main.scale,
                                    inset: CGFloat = 0) -> UIView {
        let origin = CGPoint(x: inset / 2, y: 0)
        let size = CGSize(width: UIScreen.main.bounds.width - inset, height: height)
        let view = UIView(frame: CGRect(origin: origin, size: size))
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        return view
    }

    static func verticalSeparator(_ color: UIColor = .lightGray,
                                  width: CGFloat = 1 / UIScreen.main.scale,
                                  inset: CGFloat = 0) -> UIView {
        let origin = CGPoint(x: inset / 2, y: 0)
        let size = CGSize(width: width, height: 0)
        let view = UIView(frame: CGRect(origin: origin, size: size))
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        view.backgroundColor = color
        return view
    }

    static func embedded(_ view: UIView, inset: CGFloat = 0) -> UIView {
        let rootView = UIView()
        rootView.addSubview(view)
        view.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(inset)
        }
        return rootView
    }

}
