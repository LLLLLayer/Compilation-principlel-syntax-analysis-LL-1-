//
//  ContentView.swift
//  GrammaticalAnalysis_LL(1)
//
//  Created by Layer on 2019/11/27.
//  Copyright © 2019 Layer. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var numsString: String = "1"
    @State var startSymbol: String = ""
    @State var nums: Int = 1
    @State var leftString: String = ""
    @State var rightString: String = ""
    @State var grammarList: [Grammar] = []
    @State var grammar: Grammar = Grammar()
    @State var showRes: String = ""
    @State var showTable: String = ""
    @State var testString: String = ""
    @State var GA: GrammaticalAnalysis = GrammaticalAnalysis([],"")
    var body: some View {
        VStack {
            Text("GrammaticalAnalysis_LL(1)")
                .font(.title)
                .fontWeight(.thin)
                .multilineTextAlignment(.center)
                //.frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                Spacer()
                Text("产生式数：")
                TextField("请输入产生式个数", text: $numsString)
                Spacer()
                Text("开始符号：")
                TextField("请输入产生式开始的符号", text: $startSymbol)
                Spacer()
                Button(action:{
                    //print(self.numsString)
                    //print(self.startSymbol)
                    self.showRes = self.showRes + "产生式数量：\n" + self.numsString + "\n"
                    self.showRes = self.showRes + "产生式开始符号：\n" + self.startSymbol + "\n"
                }){
                    Text("确定")
                }
                Spacer()
            }
            HStack {
                Spacer()
                Text("第\(nums)产生式左：")
                TextField("请输入产生式左", text: $leftString)
                Spacer()
                Text("第\(nums)产生式右：")
                TextField("请输入产生式右", text: $rightString)
                Spacer()
                Button(action: {
                    if self.nums <= Int(self.numsString) ?? 0 {
                        if self.nums == 1 {
                            self.showRes = self.showRes + "输入的产生式为：\n"
                        }
                        self.showRes = self.showRes + self.leftString + " -> " + self.rightString + "\n"
                        self.nums = self.nums + 1
                        var x = false
                        for i in 0..<self.grammarList.count {
                            if self.grammarList[i].leftString == self.leftString {
                                self.grammarList[i].rightString.append(self.rightString)
                                x = true
                                break
                            }
                        }
                        if x == false {
                            self.grammar.leftString = self.leftString
                            self.grammar.rightString.append(self.rightString)
                            self.grammarList.append(self.grammar)
                            self.grammar = Grammar()
                        }
                        self.leftString = ""
                        self.rightString = ""
                        for g in self.grammarList {
                            print(g)
                        }
                    }
                    if self.nums == (Int(self.numsString) ?? 0) + 1 {
                        self.GA = GrammaticalAnalysis(self.grammarList,self.startSymbol)
                        self.GA.EliminatingLeftRecursion()
                        self.GA.CalFirst()
                        self.GA.CalFollow()
                        self.GA.CreateTable()
                        self.showRes = self.showRes + self.GA.showRes
                        
                        let temp = self.GA.table
                        var str = ""
                        for (noSymbol,endSymbolAndReplice) in temp {
                            str = str + noSymbol + " : \n"
                            for (endSymbol, replice) in endSymbolAndReplice {
                                str = str + "遇到 " + endSymbol + " 则换 " + replice  + "\n"
                            }
                        }
                        
                        self.showRes = self.showRes + str
                        
                        self.nums = self.nums - 1
                    }

                }){
                    Text("确定")
                }
                Spacer()
            }
            
            HStack {
                Spacer()
                Text("测试：")
                TextField("在此输入测试语句",text: $testString)
                Button(action: {
                    if self.GA.Test(s: self.testString) == true {
                        self.showRes = self.showRes + self.testString + "  Acc!" + "\n"
                    }
                    else {
                        self.showRes = self.showRes + self.testString + "  Can't Acc!" + "\n"
                    }
                }){
                    Text("确定")
                }
                Spacer()
            }
            Text("语法分析结果")
            
            HStack {
                TextField(self.showRes, text: $showRes)
                //TextField(self.showTable, text: $showTable)
            }
            Button(action:{
                self.numsString = "1"
                self.startSymbol = ""
                self.nums = 1
                self.leftString = ""
                self.rightString = ""
                self.grammarList = []
                self.grammar = Grammar()
                self.showRes = ""
                self.showTable = ""
                self.testString = ""
                self.GA = GrammaticalAnalysis([],"")
            }){
                Text("清除")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
