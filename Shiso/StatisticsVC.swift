//
//  StatisticsVC.swift
//  Shiso
//
//  Created by Lucy DeLaurentis on 9/1/18.
//  Copyright © 2018 Micah DeLaurentis. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class StatisticsVC: UIViewController {

var userID = FirebaseConstants.CurrentUserID
let numberOfGames = UILabel()
let gamesWon = UILabel()
let gamesLost = UILabel()
let gamesTied = UILabel()
let highScore = UILabel()
let longestWinStreak = UILabel()
let highScore_2min = UILabel()
let highScore_5min = UILabel()
let highScore_10min = UILabel()
let ranking_2min = UILabel()
let ranking_5min = UILabel()
    
var userStats = UserStats()
    var backBtn: UIButton = {
        let bb = UIButton()
        bb.frame = CGRect(origin: CGPoint(x: 10, y: 30), size: CGSize(width: 70, height: 30))
        bb.layer.cornerRadius = 3
        bb.backgroundColor = .white
        bb.setTitle("🔙", for: .normal)
        
        return bb
    }()

override func viewDidLoad() {
        super.viewDidLoad()
    print("In stats view did load")
    guard userID != nil
        else {
        print("no user ID. can't get stats!")
        return
            
    }

    view.addSubview(backBtn)
 
    
    backBtn.addTarget(self, action: #selector(backBtnPushed), for: .touchUpInside)
 
    Fire.dataService.getStats(forUserID: userID!) {
        (stats, hs2min, hs5min)  in
        
        print("MY STATS: \(stats)")
        self.numberOfGames.text = "Total games played: (\(stats.numberOfGames))"
        self.gamesWon.text = "Total # of Games Won: \(stats.numberOfWins)"
        self.gamesLost.text = "Games Lost: \(stats.numberOfLosses)"
        self.gamesTied.text = "Games Tied: \(stats.numberOfWins >= stats.numberOfLosses ? stats.numberOfWins - stats.numberOfLosses : stats.numberOfLosses - stats.numberOfWins)"
        self.highScore.text = "High Score: \(stats.highScore)"
        self.longestWinStreak.text = "Longest Winning Streak: \(stats.longestWinStreak)"
        
        if stats.singlePlayer_2min_HighScore != nil {
        self.highScore_2min.text = "High Score (2 min.): \(stats.singlePlayer_2min_HighScore!)"
           
            if hs2min != nil {
                var count = 0
                for score in hs2min! {
                    if score <= stats.singlePlayer_2min_HighScore! {
                         count += 1
                    }
                }
                let rank2min = hs2min!.count - count + 1
                
                let pctlRank: Double = Double(100*rank2min/hs2min!.count)
                let pctlRankInt = Int(round(pctlRank))
                self.ranking_2min.text = "  -Percentile rank 2 min.: \(pctlRankInt)th"
            }
            }
        else {
            self.highScore_2min.text = "High Score (2 min.): ?"
        }
     
        if stats.singlePlayer_5min_HighScore != nil {
            self.highScore_5min.text = "High Score (5 min.): \(stats.singlePlayer_5min_HighScore!)"
            
            if hs5min != nil {
                var count = 0
                for score in hs5min! {
                    if score <= stats.singlePlayer_5min_HighScore! {
                        count += 1
                    }
                }
                let rank5min = hs5min!.count - count + 1
                
                let pctlRank: Double = Double(100*rank5min/hs5min!.count)
                let pctlRankInt = Int(round(pctlRank))
                self.ranking_5min.text = "  -Percentile rank 5 min.: \(pctlRankInt)th"
            }
        }
        else {
            self.highScore_5min.text = "High Score (5 min.): ?"
        }
        
         self.highScore_10min.text = "High Score (10 min.): \(stats.singlePlayer_10min_HighScore)"
        
        
        let opponentsGamesLbl = UILabel()
        opponentsGamesLbl.text = "Games Against Opponents"
        let singleGamesLbl = UILabel()
       
        singleGamesLbl.text = "Single Player Games"
        
        self.setUpLabel(statLabel: opponentsGamesLbl, fontSize: 25, fontName: "Arial-BoldMT",viewToAnchorBelow: self.backBtn)
        
        self.setUpLabel(statLabel: self.numberOfGames,fontName: "Arial-ItalicMT",viewToAnchorBelow: opponentsGamesLbl)
        
        self.setUpLabel(statLabel: self.gamesWon, fontName: "Arial-ItalicMT", viewToAnchorBelow: self.numberOfGames)
        
        self.setUpLabel(statLabel: self.gamesLost,  fontName: "Arial-ItalicMT",viewToAnchorBelow: self.gamesWon)
      
        self.setUpLabel(statLabel: self.longestWinStreak, fontName: "Arial-ItalicMT", viewToAnchorBelow: self.gamesLost)
      
        
        self.setUpLabel(statLabel: singleGamesLbl, fontSize: 25, fontName: "Arial-BoldMT", viewToAnchorBelow: self.longestWinStreak)
        
        self.setUpLabel(statLabel: self.highScore_2min,  fontName: "Arial-ItalicMT", viewToAnchorBelow:  singleGamesLbl)
        
         self.setUpLabel(statLabel: self.ranking_2min,   fontName: "Arial-ItalicMT", viewToAnchorBelow: self.highScore_2min)
        
        self.setUpLabel(statLabel: self.highScore_5min,   fontName: "Arial-ItalicMT", viewToAnchorBelow: self.ranking_2min)
          self.setUpLabel(statLabel: self.ranking_5min,   fontName: "Arial-ItalicMT", viewToAnchorBelow: self.highScore_5min)
        
        
        self.setUpLabel(statLabel: self.highScore_10min,   fontName: "Arial-ItalicMT", viewToAnchorBelow: self.ranking_5min)
        
     
        
     
    }
    
}
    
    func setUpLabel(statLabel: UILabel, fontSize: CGFloat = 20, fontName: String, viewToAnchorBelow: UIView?) {
        print("In stats set up label")
        statLabel.translatesAutoresizingMaskIntoConstraints = false
        statLabel.font = UIFont(name: fontName, size: fontSize)
        statLabel.textColor = .white
        statLabel.font = UIFont(name: fontName, size: fontSize)
    
        view.addSubview(statLabel)
        
        if let viewToAnchorTo = viewToAnchorBelow {
            statLabel.topAnchor.constraint(equalTo: viewToAnchorTo.bottomAnchor, constant: 20).isActive = true
            statLabel.rightAnchor.constraint(equalTo:  view.rightAnchor).isActive = true
            statLabel.leftAnchor.constraint(equalTo:  view.leftAnchor, constant: 20).isActive = true
            statLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
            
        }
      
    }
    
    func backBtnPushed() {
     
        
        if let presentingVC = presentingViewController as? GameViewController {
            if let skV = presentingVC.view as? SKView {
                if skV.scene != nil {
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    self.dismiss(animated: false, completion: nil)
                    presentingVC.presentDisplayVC()
                }
                
            }
          
        }

      
     
    }

    
}
