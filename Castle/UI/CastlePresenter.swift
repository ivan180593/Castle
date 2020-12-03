//
//  CastlePresenter.swift
//  Castle
//
//  Created by Iván Estévez Nieto on 2/12/20.
//

import Foundation

protocol CastleViewProtocol: AnyObject {
    func setNewWindowsStatus(windows: [Window])
    func showStatus(status: String)
    func showWinners(winners: [Int])
}

final class CastlePresenter {
    private weak var view: CastleViewProtocol?
    private let totalWindows = 64
    private var initialWindows = [Window]()
    private var visitors = [Visitor]()
    
    func attachView(_ view: CastleViewProtocol) {
        self.view = view
    }
    
    func setup() {
        var index = 1
        repeat {
            initialWindows.append(Window(id: index))
            visitors.append(Visitor(id: index))
            index += 1
        } while index <= totalWindows
    }
    
    func getWindows() -> [Window] {
        initialWindows
    }
    
    func resetWindows() -> [Window] {
        initialWindows
    }
    
    func windowsStatus(_ windows: [Window]) {
        let open = windows.filter({ $0.status == .open }).count
        let closed = windows.filter({ $0.status == .closed }).count
        let leftOpen = windows.filter({ $0.status == .leftOpen }).count
        let rightOpen = windows.filter({ $0.status == .rightOpen }).count
        view?.showStatus(status: """
                                    Open: \(open)
                                    Closed: \(closed)
                                    Left open: \(leftOpen)
                                    Right open: \(rightOpen)
                                """)
    }
    
    func windowsWinners(_ windows: [Window]) {
        var winners = [Int]()
        for window in windows {
            var previousOK = false
            var nextOK = false
            let previousWindow = windows.first(where: { $0.id == window.id - 1 })
            let nextWindow = windows.first(where: { $0.id == window.id + 1 })
            
            if let previousWindow = previousWindow {
                if previousWindow.status == .closed {
                    previousOK = true
                }
            } else { // It's the first
                previousOK = true
            }
            if let nextWindow = nextWindow {
                if nextWindow.status == .closed {
                    nextOK = true
                }
            } else { // It's the last
                nextOK = true
            }
            
            if window.status == .open && previousOK && nextOK {
                winners.append(window.id)
            }
        }
        view?.showWinners(winners: winners)
    }
    
    func openWindowsWinner(_ windows: [Window]) {
        let winners = windows.filter({ $0.status == .open }).map({ $0.id })
        view?.showWinners(winners: winners)
    }
    
    func proccessWindows(_ windows: [Window]) {
        var newWindows = windows
        for visitor in visitors {
            for index in 0..<windows.count {
                if visitor.id == 1 { // Open left
                    newWindows[index].status = .leftOpen
                    newWindows[index].recalculateStatus()
                    
                } else if visitor.id == 2 { // Open right multiple 2
                    if newWindows[index].id.isMultiple(of: 2) {
                        newWindows[index].rightOpened = true
                    }
                    newWindows[index].recalculateStatus()
                    
                } else if visitor.id == 64 { // Open or close right
                    newWindows[index].rightOpened.toggle()
                    newWindows[index].recalculateStatus()
                    
                } else if visitor.id.isMultiple(of: 2) { // Open right closed multiple of visitor id, close left opened multiple of visitor id
                    if newWindows[index].id.isMultiple(of: visitor.id) {
                        if !newWindows[index].rightOpened {
                            newWindows[index].rightOpened = true
                        }
                        if newWindows[index].leftOpened {
                            newWindows[index].leftOpened = false
                        }
                    }
                    newWindows[index].recalculateStatus()

                } else { // Open left closed multiple of visitor id, close right opened multiple of visitor id
                    if newWindows[index].id.isMultiple(of: visitor.id) {
                        if !newWindows[index].leftOpened {
                            newWindows[index].leftOpened = true
                        }
                        if newWindows[index].rightOpened {
                            newWindows[index].rightOpened = false
                        }
                    }
                    newWindows[index].recalculateStatus()
                }
            }
        }
        view?.setNewWindowsStatus(windows: newWindows)
    }
}
