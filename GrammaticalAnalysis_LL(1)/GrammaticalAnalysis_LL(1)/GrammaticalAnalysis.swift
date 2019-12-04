//
//  GrammaticalAnalysis.swift
//  GrammaticalAnalysis_LL(1)
//
//  Created by Layer on 2019/11/27.
//  Copyright © 2019 Layer. All rights reserved.
//

import Foundation

struct Grammar {
    var isUseful: Bool = false//产生式是否有效
    var leftString: String = ""//产生式箭头左边
    var rightString: [String] = []//产生式箭头右边
    var first: [String] = []//first集
    var follow: [String] = []//fillow集
}

class GrammaticalAnalysis {
    var grammarList: [Grammar] = []//产生式集合
    var startSymbol: String = ""//开始符号
    var NoSymbol: [String:Int] = [:]//非终结符的集合，（字母，出现位置）
    var EndSymbol: [String] = []
    var showRes: String = ""
    var table: [String: [(String,String)]] = [:]//[非终结符:(终结符,转移)]
    
    init(_ inGrammerList: [Grammar], _ inStartSymbol: String) {//构造函数
        self.grammarList = inGrammerList
        self.startSymbol = inStartSymbol
    }
    
    func EliminatingLeftRecursion() {//消除左递归
        //非终结符的集合
        var num: Int = 0
        for grammer in grammarList {
            if NoSymbol[grammer.leftString] == nil {
                NoSymbol[grammer.leftString] = num
                num = num + 1
            }
        }
        //消除间接左递归
        for i in 0..<grammarList.count {
            for j in 0..<i {
                let nowLeftString = grammarList[j].leftString
                var nowRightString: [String] = []
                for k in 0..<grammarList[i].rightString.count {
                    if String(grammarList[i].rightString[k][grammarList[i].rightString[k].startIndex]) == nowLeftString {
                        for l in 0..<grammarList[k].rightString.count {
                            var temp: String = ""
                            temp = grammarList[i].rightString[k]
                            temp.remove(at: temp.startIndex)
                            temp = grammarList[j].rightString[l] + temp
                            nowRightString.append(temp)
                        }
                    }
                }
                for k in 0..<grammarList[i].rightString.count {
                    if String(grammarList[i].rightString[k][grammarList[i].rightString[k].startIndex]) != nowLeftString {
                        nowRightString.append(grammarList[i].rightString[k])
                    }
                }
                grammarList[i].rightString = nowRightString
            }
        }
        showRes = showRes + "消除间接左递归结果：\n"
        for grammer in grammarList {
            var temp: String = grammer.leftString + " -> " + grammer.rightString[0]
            for i in 1..<grammer.rightString.count {
                temp = temp + " | " + grammer.rightString[i]
            }
            showRes = showRes + temp + "\n"
        }
        //消除直接左递归
        var grammarListTemp = grammarList
        for gr in 0..<grammarList.count {
            let grammar = grammarList[gr]
            for r in 0..<grammar.rightString.count {
                let right = grammar.rightString[r]
                if String(right[right.startIndex]) == grammar.leftString {
                    var newGrammar = Grammar()
                    var changeGrammar = Grammar()
                    changeGrammar.leftString = grammar.leftString
                    changeGrammar.rightString = []
                    newGrammar.leftString = grammar.leftString + "'"
                    newGrammar.rightString = []
                    for i in 0..<grammar.rightString.count {
                        if String(grammar.rightString[i][grammar.rightString[i].startIndex]) == grammar.leftString{//S->Sabc => S'->abcS'
                            var temp: String = ""
                            temp = grammar.rightString[i]
                            temp.remove(at: temp.startIndex)
                            temp = temp + newGrammar.leftString
                            newGrammar.rightString.append(temp)
                        }
                        else { //S->abc => S->abcS'
                            var temp: String = ""
                            temp = grammar.rightString[i]
                            temp = temp + newGrammar.leftString
                            changeGrammar.rightString.append(temp)
                        }
                    }
                    grammarListTemp[gr] = changeGrammar
                    newGrammar.rightString.append("ε")
                    grammarListTemp.append(newGrammar)
                }
            }
        }
        grammarList = grammarListTemp
        showRes = showRes + "消除直接左递归结果：\n"
        for grammer in grammarList {
            var temp: String = grammer.leftString + " -> " + grammer.rightString[0]
            for i in 1..<grammer.rightString.count {
                temp = temp + " | " + grammer.rightString[i]
            }
            showRes = showRes + temp + "\n"
        }
        //消除左递归结果，删除无效规则
        for i in 0..<grammarList.count {
            if grammarList[i].leftString == startSymbol {
                helper(from: i)   //从当前文法开始找，有用的isusful标记为1
            }
        }
        grammarListTemp = []
        for i in 0..<grammarList.count{
            if grammarList[i].isUseful{
                grammarListTemp.append(grammarList[i])
            }
        }
        grammarList = grammarListTemp
        NoSymbol=[:]
        showRes = showRes + "消除左递归结果：\n"
        for grammer in grammarList {
            var temp: String = grammer.leftString + " -> " + grammer.rightString[0]
            for i in 1..<grammer.rightString.count {
                temp = temp + " | " + grammer.rightString[i]
            }
            showRes = showRes + temp + "\n"
        }
    }
    
    func helper(from: Int) {//递归搜寻有效的文法规则
        if grammarList[from].isUseful == true {
            return
        }
        grammarList[from].isUseful = true
        for i in 0..<grammarList[from].rightString.count{
            let right=grammarList[from].rightString[i]
            for j in 0..<right.count {
                if j<right.count-1 {//可能有"'"
                    if right[right.index(right.startIndex, offsetBy: j+1)] == "'" {//带'
                        let s=String(right[right.index(right.startIndex,offsetBy: j)])+String(right[right.index(right.startIndex, offsetBy: j+1)])
                        // right[j]+"'"
                        for l in 0..<grammarList.count {
                            if grammarList[l].leftString == s {
                                helper(from: l)
                            }
                        }
                        continue
                    }
                }
                //不满足 right[j]+"'"
                let s=String(right[right.index(right.startIndex, offsetBy: j)])
                for l in 0..<grammarList.count{
                    if grammarList[l].leftString == s{
                        helper(from: l)
                    }
                }
            }
        }
    }
    
    func CalFirst() {//求first集
        for gr in 0..<grammarList.count {
            let grammar = grammarList[gr]
            for right in grammar.rightString {
                var hasNil = true
                for i in 0..<right.count {
                    if hasNil == false {//不需要处理空
                        break
                    }
                    hasNil = false
                    if right[right.index(right.startIndex, offsetBy: i)] == "'" { //当前字符是“'”，连着上一个，跳过
                        continue
                    }
                    var temp: String
                    if i < right.count - 1 {
                        if right[right.index(right.startIndex,offsetBy:  i + 1)] == "'" { //带“'”的符号，一起处理
                            temp = String(right[right.index(right.startIndex,offsetBy: i)])+String(right[right.index(right.startIndex,offsetBy: i+1)])
                        }
                        else {
                            temp = String(right[right.index(right.startIndex,offsetBy: i)])
                        }
                    }
                    else{
                        temp = String(right[right.index(right.startIndex,offsetBy: i)])
                    }
                    if (NoSymbol[temp] != nil) {//该符号在非终结符字典中
                        var follow: [String] = []
                        dfsFirst(first: &follow, s: temp, hasNil: &hasNil)  //递归查找
                        for k in 0..<follow.count {
                            if grammarList[gr].first.firstIndex(of: follow[k]) == nil {
                                grammarList[gr].first.append(follow[k])
                            }
                        }
                    }
                    else {//该符号为终结符，添加
                        if grammarList[gr].first.firstIndex(of: temp) == nil {
                            grammarList[gr].first.append(temp)
                            break
                        }
                    }
                }
            }
        }
        showRes = showRes + "First集结果：\n"
        for grammar in grammarList {
            NoSymbol[grammar.leftString] = 1   //标记存在
            var temp: String=""
            temp = grammar.leftString + " { "
            temp = temp + grammar.first[0]
            for j in 1..<grammar.first.count
            {
                temp = temp + "," + grammar.first[j]
            }
            showRes = showRes + temp + " }\n"
        }
    }
    
    func dfsFirst(first: inout [String],s: String,hasNil: inout Bool) {//查找非终结符的first集
        for gr in 0..<grammarList.count {
            if grammarList[gr].leftString == s {
                if grammarList[gr].first.count > 0 {//已经计算过first集
                    for i in grammarList[gr].first {
                        if first.firstIndex(of: i) == nil {
                            if i == "ε" {
                                hasNil = true
                            }
                            first.append(i)
                        }
                    }
                }
                else{
                    for right in grammarList[gr].rightString {
                        var dfsHasNil=true
                        for i in 0..<right.count {
                            if dfsHasNil == false {//无空，停止递归
                                break
                            }
                            if i>0 {
                                hasNil = true
                            }
                            dfsHasNil = false
                            if right[right.index(right.startIndex,offsetBy: i)] == "'" {//字符是"'",同上一个字符，跳过
                                continue
                            }
                            var s: String
                            if i<right.count-1 {
                                if right[right.index(right.startIndex, offsetBy: i+1)] == "'" {//带“'”的符号
                                    s=String(right[right.index(right.startIndex,offsetBy: i)])+String(right[right.index(right.startIndex,offsetBy: i+1)])
                                }
                                else{
                                    s=String(right[right.index(right.startIndex, offsetBy: i)])
                                }
                            }
                            else{
                                s=String(right[right.index(right.startIndex, offsetBy: i)])
                            }
                            if (NoSymbol[s] != nil) {//非终结符
                                var follow: [String] = []
                                dfsFirst(first: &follow, s: s, hasNil: &dfsHasNil)//继续递归查找
                                for k in 0..<follow.count{
                                    if grammarList[gr].first.firstIndex(of: follow[k]) == nil {//添加到当前的first中
                                        grammarList[gr].first.append(follow[k])
                                    }
                                    if first.firstIndex(of: follow[k]) == nil {//添加到引起递归的firstk中
                                        first.append(follow[k])
                                    }
                                    if (s == "ε") {
                                        hasNil=true
                                    }
                                }
                            }
                            else {//终结符
                                if grammarList[gr].first.firstIndex(of: s) == nil{
                                    if grammarList[gr].first.firstIndex(of: s) == nil {//添加到当前的first中
                                        grammarList[gr].first.append(s)
                                    }
                                    if first.firstIndex(of: s) == nil {//添加到引起递归的firstk中
                                        first.append(s)
                                    }
                                    if (s == "ε") {
                                        hasNil=true
                                    }
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func CalFollow() {//求follow集
        //对开始文法加入结束符号“$“
        for i in 0..<grammarList.count {
            if grammarList[i].leftString == startSymbol {
                if grammarList[i].follow.firstIndex(of: "$") == nil {
                    grammarList[i].follow.append("$")
                }
            }
            for j in 0..<grammarList.count {//j循环grammar
                for k in 0..<grammarList[j].rightString.count {//k循环rightString
                    if grammarList[i].leftString.count == 1 {//单字母
                        for rightStringNum in 0..<grammarList[j].rightString[k].count {
                            var s = rightStringNum
                            if (s < grammarList[j].rightString[k].count-1 && String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s)]) == grammarList[i].leftString && String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s+1)]) != "'") || (s == grammarList[j].rightString[k].count-1 && String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s)]) == grammarList[i].leftString) {//左部有相等的右部
                                var hasNil = true
                                s = s - 1
                                while hasNil == true {
                                    s = s + 1
                                    if s <= grammarList[j].rightString[k].count-1 {
                                        if (grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s)]) == "'" {
                                            continue
                                        }
                                    }
                                    hasNil = false
                                    var followSet: [String] = []
                                    if s < grammarList[j].rightString[k].count-1 {  //右侧还有字母
                                        var str = ""
                                        if (s < grammarList[j].rightString[k].count-2 && grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s+2)] == "'") {  //右侧的有'
                                            str = String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s+1)]) + String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy:s+2)])
                                            s = s + 1
                                        }
                                        else {   //右侧为单个字符，判断是不是文法左部
                                            str = String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s+1)])
                                        }
                                        if NoSymbol[str] != nil {
                                            for t in 0..<grammarList.count {
                                                if grammarList[t].leftString == str {
                                                    for tt in grammarList[t].first {
                                                        if tt != "ε" {
                                                            if grammarList[i].follow.firstIndex(of: tt) == nil {
                                                                grammarList[i].follow.append(tt)
                                                            }
                                                        }
                                                        else {
                                                            hasNil = true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        else {
                                            if grammarList[i].follow.firstIndex(of: str) == nil {
                                                grammarList[i].follow.append(str)
                                            }
                                        }
                                    }
                                    else {//右侧没有字母了
                                        let follow = grammarList[j].follow
                                        if follow.count > 0 {
                                            for k in follow {
                                                if grammarList[i].follow.firstIndex(of: k) == nil {
                                                    grammarList[i].follow.append(k)
                                                }
                                            }
                                        }
                                        else {   //又要求左边这个的follow...无穷无尽啊！！
                                            if grammarList[i].leftString != grammarList[j].leftString {
                                                dfsFollow(SfollowSet: &followSet, SearchS: grammarList[j].leftString, Shasnil: &hasNil)
                                                for k in followSet {
                                                    if grammarList[j].follow.firstIndex(of: k) == nil {
                                                        grammarList[j].follow.append(k)
                                                    }
                                                    if grammarList[i].follow.firstIndex(of: k) == nil {
                                                        grammarList[i].follow.append(k)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else {//俩字母，带'
                        for rightStringNum in 0..<grammarList[j].rightString[k].count {
                            var s=rightStringNum
                            if (s==grammarList[j].rightString[k].count-1) {
                                break
                            }
                            if String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy:s)])+String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s+1)]) == grammarList[i].leftString {   //i左部有相等的右部
                                var hasnil=true
                                s = s - 1
                                while hasnil==true {
                                    s = s + 1
                                    if s<=grammarList[j].rightString[k].count - 1 {
                                        if (grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy:s)]) == "'" {
                                            continue
                                        }
                                    }
                                    hasnil = false
                                    var followSet: [String] = []
                                    if s < grammarList[j].rightString[k].count - 2 {   //右侧还有字母
                                        var str = ""
                                        if (s < grammarList[j].rightString[k].count - 3 && grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s + 3)] == "'") {   //右侧的有'
                                            str = String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s + 2)]) + String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s + 3)])
                                            s = s + 2
                                        }
                                        else {   //右侧为单个字符，判断是不是文法左部
                                            str = String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s + 2)])
                                        }
                                        if NoSymbol[str] != nil {
                                            for t in 0..<grammarList.count {
                                                if grammarList[t].leftString == str {
                                                    for tt in grammarList[t].first {
                                                        if tt != "ε" {
                                                            if grammarList[i].follow.firstIndex(of: tt) == nil {
                                                                grammarList[i].follow.append(tt)
                                                            }
                                                        }
                                                        else {
                                                            hasnil=true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        else {
                                            if grammarList[i].follow.firstIndex(of: str) == nil {
                                                grammarList[i].follow.append(str)
                                            }
                                        }
                                    }
                                    else {   //右侧没有字母了
                                        let follow=grammarList[j].follow
                                        if follow.count>0 {
                                            for k in follow {
                                                if grammarList[i].follow.firstIndex(of: k) == nil {
                                                    grammarList[i].follow.append(k)
                                                }
                                            }
                                        }
                                        else {
                                            if grammarList[i].leftString != grammarList[j].leftString {
                                                dfsFollow(SfollowSet: &followSet, SearchS: grammarList[j].leftString, Shasnil: &hasnil)
                                                for k in followSet {
                                                    if grammarList[j].follow.firstIndex(of: k) == nil {
                                                        grammarList[j].follow.append(k)
                                                    }
                                                    if grammarList[i].follow.firstIndex(of: k) == nil {
                                                        grammarList[i].follow.append(k)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        showRes = showRes + "Follow集结果：\n"
        for grammar in grammarList {
            var s: String = ""
            s=grammar.leftString + " { "
            s = s + grammar.follow[0]
            for j in 1..<grammar.follow.count {
                s = s + "," + grammar.follow[j]
            }
            showRes = showRes + s + " }\n"
        }
    }
    
    func dfsFollow(SfollowSet: inout [String],SearchS: String,Shasnil: inout Bool) {
        if (SearchS == startSymbol) {    //开始的节点，加入$
            if (SfollowSet.firstIndex(of: "$") == nil) {
                SfollowSet.append("$")
            }
        }
        for j in 0..<grammarList.count { //查找的grammar
            for k in 0..<grammarList[j].rightString.count {  //查找的grammar的右部
                if SearchS.count==1 {   //单个字母
                    for pp in 0..<grammarList[j].rightString[k].count {
                        var s = pp
                        if (s < grammarList[j].rightString[k].count-1 && String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s)]) == SearchS && String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s+1)]) != "'") || (s == grammarList[j].rightString[k].count-1 && String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s)]) == SearchS) { //i左部有相等的右部
                            var hasnil = true
                            s = s - 1
                            while hasnil == true {
                                s = s + 1
                                if s <= grammarList[j].rightString[k].count-1 {
                                    if (grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s)]) == "'" {
                                        continue
                                    }
                                }
                                hasnil = false
                                var followSet: [String]=[]
                                if s < grammarList[j].rightString[k].count-1 {  //右侧还有字母
                                    var str = ""
                                    if (s<grammarList[j].rightString[k].count-2 && grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s+2)] == "'"){
                                        str = String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s + 1)]) + String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s+2)])
                                        s = s + 1
                                    }
                                    else {//右侧为单个字符，判断是不是文法左部
                                        str = String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s+1)])
                                    }
                                    if NoSymbol[str] != nil {
                                        for t in 0..<grammarList.count {
                                            if grammarList[t].leftString == str {
                                                for tt in grammarList[t].first {
                                                    if tt != "ε" {
                                                        if (SfollowSet.firstIndex(of: tt) == nil) {
                                                            SfollowSet.append(tt)
                                                        }
                                                    }
                                                    else {
                                                        hasnil=true
                                                        Shasnil=true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        SfollowSet.append(str)
                                    }
                                }
                                else {//右侧没有字符
                                    let follow = grammarList[j].follow
                                    if follow.count > 0 {
                                        for k in follow {
                                            if SfollowSet.firstIndex(of: k) == nil {
                                                SfollowSet.append(k)
                                            }
                                        }
                                    }
                                    else {
                                        if SearchS != grammarList[j].leftString {
                                            dfsFollow(SfollowSet: &followSet, SearchS: grammarList[j].leftString, Shasnil: &hasnil)
                                            for k in followSet {
                                                if grammarList[j].follow.firstIndex(of: k) == nil {
                                                    grammarList[j].follow.append(k)
                                                }
                                                if SfollowSet.firstIndex(of: k) == nil {
                                                    SfollowSet.append(k)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else {//带'
                    for pp in 0..<grammarList[j].rightString[k].count {
                        var s=pp
                        if (s == grammarList[j].rightString[k].count-1) {
                            break
                        }
                        if String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s)])+String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex, offsetBy: s+1)]) == SearchS {  //i左部有相等的右部
                            var hasnil=true
                            s = s - 1
                            while hasnil==true
                            {
                                s=s+1
                                if s <= grammarList[j].rightString[k].count-1
                                {
                                    if (grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s)]) == "'" {
                                        continue
                                    }
                                }
                                hasnil=false
                                var followSet: [String]=[]
                                if s < grammarList[j].rightString[k].count-2 {  //右侧还有字母
                                    var str=""
                                    if (s<grammarList[j].rightString[k].count-3 && grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s+3)] == "'") {  //右侧的有'
                                        str=String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s+2)]) + String(grammarList[j].rightString  [k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s + 3)])
                                        s = s + 2
                                    }
                                    else {//右侧为单个字符，判断是不是文法左部
                                        str = String(grammarList[j].rightString[k][grammarList[j].rightString[k].index(grammarList[j].rightString[k].startIndex,offsetBy: s + 2)])
                                    }
                                    if NoSymbol[str] != nil {
                                        for t in 0..<grammarList.count {
                                            if grammarList[t].leftString == str {
                                                for tt in grammarList[t].first {
                                                    if tt != "ε" {
                                                        if (SfollowSet.firstIndex(of: tt) == nil) {
                                                            SfollowSet.append(tt)
                                                        }
                                                    }
                                                    else {
                                                        hasnil=true
                                                        Shasnil=true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        if (SfollowSet.firstIndex(of: str) == nil) {
                                            SfollowSet.append(str)
                                        }
                                    }
                                }
                                else {//右侧没有字符
                                    let follow=grammarList[j].follow
                                    if follow.count>0 {
                                        for k in follow {
                                            if SfollowSet.firstIndex(of:k) == nil {
                                                SfollowSet.append(k)
                                            }
                                        }
                                    }
                                    else {
                                        if SearchS != grammarList[j].leftString {
                                            dfsFollow(SfollowSet: &followSet, SearchS: grammarList[j].leftString, Shasnil: &hasnil)
                                            for k in followSet {
                                                if grammarList[j].follow.firstIndex(of: k) == nil {
                                                    grammarList[j].follow.append(k)
                                                }
                                                if SfollowSet.firstIndex(of: k) == nil {
                                                    SfollowSet.append(k)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func CreateTable() {
        //求终结符
        for gram in grammarList {
            for right in gram.rightString {
                for i in 0..<right.count {
                    if i<right.count-1 {//后面还有字符
                        if right[right.index(right.startIndex,offsetBy: i+1)] == "'" {
                            continue
                        }
                        let nowchar=String(right[right.index(right.startIndex,offsetBy: i)])
                        if (nowchar) != "ε" && nowchar.count>0 {
                            if NoSymbol[nowchar] == nil {
                                if (EndSymbol.firstIndex(of: nowchar) == nil) {
                                    EndSymbol.append(nowchar)
                                }
                            }
                        }
                    }
                    else {
                        let nowchar=String(right[right.index(right.startIndex,offsetBy:i)])
                        if nowchar != "ε" && nowchar != "'" {
                            if NoSymbol[nowchar] == nil {
                                if (EndSymbol.firstIndex(of: nowchar) == nil) {
                                    EndSymbol.append(nowchar)
                                }
                            }
                        }
                    }
                }
            }
        }
        EndSymbol.append("$")
        showRes = showRes + "非终结符:\n"
        var temp = ""
        for noend in NoSymbol {
            temp = temp + " " + noend.0
        }
        showRes = showRes + temp + "\n"
        showRes = showRes + "终结符: \n"
        temp = ""
        for ends in EndSymbol {
            temp=temp + " " + ends
        }
        showRes = showRes + temp + "\n"
        
        //生成表
        for grammar in grammarList { //对于每个文法G的产生式
            for first in grammar.first {
                if first != "ε" {//不是空
                    for right in grammar.rightString {
                        if String(right[right.index(right.startIndex, offsetBy: 0)]) == first {
                            let label = (first,right)
                            if table[grammar.leftString] == nil {
                                table[grammar.leftString]=[]
                            }
                            table[grammar.leftString]!.append(label)
                            break
                        }
                    }
                }
                else {//处理空字
                    for right in grammar.rightString {
                        if String(right[right.startIndex]) == first {
                            var label=(first,right)
                            for follow in grammar.follow {
                                label=(follow,right)
                                if table[grammar.leftString] == nil {
                                    table[grammar.leftString]=[]
                                }
                                table[grammar.leftString]!.append(label)
                            }
                            break
                        }
                    }
                }
            }
        }
        for i in table {
            print (i)
        }
    }
    
    func Test(s: String) ->Bool {//判断字符串是否符合该文法
        let inStr = s + "$"
        var stuck: [String] = ["$"]//加入结束符合
        stuck.append(startSymbol)//加入开始符号
        for char in inStr {//遍历输入
            while NoSymbol[stuck.last!] != nil {
                let now = stuck.popLast()!
                let label = table[now]
                if label == nil {//不存在
                    return false
                }
                for (a,b) in label! {
                    if a == String(char) {
                        var str = ""
                        var ch = b.count - 1
                        while(ch >= 0) {
                            if b[b.index(b.startIndex,offsetBy: ch)] == "'" {
                                ch = ch - 1
                                str = String(b[b.index(b.startIndex,offsetBy: ch)]) + String(b[b.index(b.startIndex,offsetBy: ch + 1)])
                            }
                            else {
                                str=String(b[b.index(b.startIndex,offsetBy: ch)])
                            }
                            stuck.append(str)
                            ch = ch - 1
                        }
                    }
                }
            }
            while (stuck.last!) == "ε" {
                stuck.popLast()!
            }
            if stuck.popLast()! != String(char) {
                return false
            }
        }
        if stuck.count == 0 {
            return true
        }
        else {
            return false
        }
    }
}
