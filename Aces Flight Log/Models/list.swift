//
//  List.swift
//  Aces Flight Log
//
//  Created by Jordan Simpson on 7/26/24.
//

import Foundation

class pickerlist: ObservableObject {
    @Published var aircraft = ["UH-60L", "UH-60M", "UH-60V", "HH-60L", "HH-60M", "CH-47", "CH-47D", "CH-47F", "CH-47G" ,"AH-64E", "AH-64D", "MH-60M", "MH-47G", "MH-47E", "UH-72", "UH-72A", "TH-67", "TH-67A", "OH-58A", "OH-58B", "OH-58C", "OH-58D", "OH-58", "OH-6", "MH-6", "OH-6A", "AH-6"]
    @Published var rcmduty = ["PI", "PC", "IP", "UT", "MF", "IE", "SP", "ME", "XP"]
    @Published var nrcmduty = ["CE", "SI", "FE", "FI", "OR"]
    @Published var condition = ["D", "N", "NG", "NS", "H", "W"]
    @Published var seatAH = ["F", "B"]
    @Published var seat = ["L", "R"]
}
