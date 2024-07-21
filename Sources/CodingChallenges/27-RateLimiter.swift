/// ## Problem
/// https://codingchallenges.substack.com/p/coding-challenge-27-rate-limiter
///

import Foundation

class SlidingWindowWeighted {
    var currentCount: Int
    var prevCount: Int
    var currentWindowStart: Date
    let windowSizeInSeconds: Int
    let maxRequestsPerWindow: Int
    
    init(windowSizeInSeconds: Int, maxRequestsPerWindow: Int) {
        self.windowSizeInSeconds = windowSizeInSeconds
        self.maxRequestsPerWindow = maxRequestsPerWindow
        self.currentCount = 0;
        self.prevCount = 0;
        self.currentWindowStart = Date.distantPast
    }
    
    func consume() -> Bool {
        let now = Date.now
        
        if (self.currentCount == 0) {
            self.currentCount = 1
            self.prevCount = 0
            self.currentWindowStart = now
            return true
        }
        
        let timePassed = seconds(from: self.currentWindowStart, to: now)
        
        if (timePassed > windowSizeInSeconds) {
            self.prevCount = self.currentCount
            self.currentCount = 1
            self.currentWindowStart = now
            return true
        }
        
        let weight: Double = Double(self.windowSizeInSeconds - timePassed) /
                                Double(self.windowSizeInSeconds);
        let weightedCount: Double = Double(self.currentCount) + Double(self.prevCount) * weight
        
        if (weightedCount > Double(self.maxRequestsPerWindow)) {
            return false
        }
        
        self.currentCount += 1
        return true;
    }
    
}

/**
 The sliding window algorithm involves:
 - Tracking a time stamped log for each consumer request. These logs are usually stored in a hash set or table that is sorted by time.
 - Logs with timestamps beyond a threshold are discarded.
 - When a new request comes in, we calculate the sum of logs to determine the request rate.
 - If the request when added to the log would exceed the threshold rate, then it is declined.
 */
class SlidingWindow {
    var requestLog: [Date]
    let windowSizeInSeconds: Int
    let maxRequestsPerWindow: Int
    
    init(windowSizeInSeconds: Int, maxRequestsPerWindow: Int) {
        requestLog = []
        self.windowSizeInSeconds = windowSizeInSeconds
        self.maxRequestsPerWindow = maxRequestsPerWindow
    }
    
    func consume() -> Bool {
        let now = Date.now
        let windowStartTime = Calendar.current.date(byAdding: .second, value: -windowSizeInSeconds, to: now)!
        
        // Filter logs to only keep entries within the current window
        var requestsWithinWindow = requestLog.filter({ $0 >= windowStartTime})
        
        if (requestsWithinWindow.count >= maxRequestsPerWindow) {
            return false
        }
        
        requestsWithinWindow.append(now)
        self.requestLog = requestsWithinWindow
        
        return true;
    }
}

/**
 The fixed window  algorithm works like this:
 - A window size of N seconds is used to track the request rate. Each incoming request increments the counter for the window.
 - If the counter exceeds a threshold, the request is discarded.
 - The windows are typically defined by the floor of the current timestamp, so 17:47:13 with a 60 second window length, would be in the 17:47:00 window.
 */
class FixedWindow {
    let windowSizeInSeconds: Int
    let maxRequestPerWindow: Int
    var windowStartTime: Date
    var requestCountInCurrentWindow: Int
    
    init(windowSizeInSeconds: Int, maxRequestPerWindow: Int) {
        self.windowSizeInSeconds = windowSizeInSeconds
        self.maxRequestPerWindow = maxRequestPerWindow
        self.windowStartTime = Date.now
        self.requestCountInCurrentWindow = 0
    }
    
    func consume() -> Bool {
        let now = Date.now
        let timePassed = seconds(from: self.windowStartTime, to: now)
        
        if (timePassed >= windowSizeInSeconds) {
            self.requestCountInCurrentWindow = 1
            self.windowStartTime = now
            return true
        }
        
        self.requestCountInCurrentWindow += 1
        if (self.requestCountInCurrentWindow > maxRequestPerWindow) {
            return false
        }
        
        return true;
    }
    
}

/**
 The token bucket algorithm works like this:
 - There is a ‘bucket’ that has capacity for N tokens. Usually this is a bucket per user or IP address.
 - Every time period a new token is added to the bucket, if the bucket is full the token is discarded.
 - When a request arrives and the bucket contains tokens, the request is handled and a token is removed from the bucket.
 - When a request arrives and the bucket is empty, the request is declined.
 */
class TokenBucket {
    let capacity: Int
    var tokens: Int
    var lastFilledTime: Date
    
    init(_ capacity: Int) {
        self.capacity = capacity
        self.tokens = capacity
        self.lastFilledTime = Date.now
    }
    
    func consume() -> Bool {
        refill()
        if (tokens < 1) {
            return false
        }
        
        tokens -= 1
        return true
    }
    
    // this has to be thread safe
    // Better is call this from a timer thread.
    func refill() {
        if (tokens == capacity) {
            return
        }
        
        let now = Date.now
        let timePassed = seconds(from: self.lastFilledTime, to: now)
        if (timePassed >= 1) {
          self.tokens = min(self.tokens + timePassed, capacity);
          self.lastFilledTime = now;
        }
    }
}

func seconds(from: Date, to: Date) -> Int {
    return Calendar.current.dateComponents([.second], from: from, to: to).second ?? 0
}
