//
//  StringComparison.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/17/24.
//

import Foundation

class StringComparison {
    static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Count = s1.count
        let s2Count = s2.count

        // If either is empty, distance is the length of the other
        if s1Count == 0 { return s2Count }
        if s2Count == 0 { return s1Count }

        // Convert strings to arrays for faster indexing
        let s1Chars = Array(s1)
        let s2Chars = Array(s2)

        // Create a 2D array for dynamic programming
        var dp = [[Int]](repeating: [Int](repeating: 0, count: s2Count + 1), count: s1Count + 1)

        for i in 0...s1Count {
            dp[i][0] = i
        }
        for j in 0...s2Count {
            dp[0][j] = j
        }

        for i in 1...s1Count {
            for j in 1...s2Count {
                let cost = s1Chars[i - 1] == s2Chars[j - 1] ? 0 : 1
                dp[i][j] = min(
                    dp[i - 1][j] + 1,    // Deletion
                    dp[i][j - 1] + 1,    // Insertion
                    dp[i - 1][j - 1] + cost // Substitution
                )
            }
        }

        return dp[s1Count][s2Count]
    }
    
    // Helper function to generate all substrings of a given string
    static func allSubstrings(of str: String) -> [String] {
        let chars = Array(str)
        var result = [String]()
        for i in 0..<chars.count {
            for j in i..<chars.count {
                let substring = String(chars[i...j])
                result.append(substring)
            }
        }
        return result
    }

}
