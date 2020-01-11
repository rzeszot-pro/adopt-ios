//
//  CardBehaviour.swift
//  Adopt
//
//  Created by Damian Rzeszot on 04/01/2020.
//  Copyright © 2020 Damian Rzeszot. All rights reserved.
//

import UIKit

class CardBehaviour: UIDynamicBehavior {

    // MARK: - Types

    enum Direction {
        case left
        case right
    }

    enum State {
        case snapping
        case moving
        case swiping
    }

    // MARK: - State

    var item: UIDynamicItem
    var state: State

    // MARK: -

    var snap: UISnapBehavior!
    var attachment: UIAttachmentBehavior!
    var push: UIPushBehavior!

    // MARK: -

    init(item: UIDynamicItem) {
        self.item = item
        state = .snapping
    }

    // MARK: - Snap

    func snap(to point: CGPoint) {
        guard snap == nil else { return }

        snap = UISnapBehavior(item: item, snapTo: point)
        snap.damping = 0.75

        addChildBehavior(snap)
    }

    func unsnap() {
        guard snap != nil else { return }

        removeChildBehavior(snap)
        snap = nil
    }

    // MARK: - Attachment

    func attach(to point: CGPoint, offset: UIOffset) {
        attachment = UIAttachmentBehavior(item: item, offsetFromCenter: offset, attachedToAnchor: point)

        addChildBehavior(attachment)
    }

    func deattach() {
        guard attachment != nil else { return }

        removeChildBehavior(attachment)
        attachment = nil
    }

    func move(to point: CGPoint) {
        attachment.anchorPoint = point
    }

    // MARK: - Push

    func push(from point: CGPoint, to direction: CGVector) {
        push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.pushDirection = direction

        addChildBehavior(push)
    }

    func unpush() {
        guard push != nil else { return }

        removeChildBehavior(push)
        push = nil
    }

}
