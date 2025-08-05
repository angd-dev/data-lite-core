import Foundation

extension String {
    /// Removes SQL comments from the string while preserving string literals.
    ///
    /// This function preserves escaped single quotes inside string literals
    /// and removes both single-line (`-- ...`) and multi-line (`/* ... */`) comments.
    ///
    /// The implementation of this function is generated using
    /// [`re2swift`](https://re2c.org/manual/manual_swift.html)
    /// from the following parsing template:
    ///
    /// ```swift
    /// @inline(__always)
    /// func removingComments() -> String {
    ///     withCString {
    ///         let yyinput = $0
    ///         let yylimit = strlen($0)
    ///         var yyoutput = [CChar]()
    ///         var yycursor = 0
    ///         loop: while yycursor < yylimit {
    ///             var llmarker = yycursor/*!re2c
    ///             re2c:define:YYCTYPE   = "CChar";
    ///             re2c:yyfill:enable    = 0;
    ///
    ///             "'" ([^'] | "''")* "'" {
    ///                 while llmarker < yycursor {
    ///                     yyoutput.append(yyinput[llmarker])
    ///                     llmarker += 1
    ///                 }
    ///                 continue loop }
    ///
    ///             "--" [^\r\n\x00]* {
    ///                 continue loop }
    ///
    ///             "/*" ([^*] | "*"[^/])* "*/" {
    ///                 continue loop }
    ///
    ///             [^] {
    ///                 yyoutput.append(yyinput[llmarker])
    ///                 continue loop }
    ///         */}
    ///         yyoutput.append(0)
    ///         return String(
    ///             cString: yyoutput,
    ///             encoding: .utf8
    ///         ) ?? ""
    ///     }
    /// }
    /// ```
    @inline(__always)
    func removingComments() -> String {
        withCString {
            let yyinput = $0
            let yylimit = strlen($0)
            var yyoutput = [CChar]()
            var yycursor = 0
            loop: while yycursor < yylimit {
                var llmarker = yycursor
                var yych: CChar = 0
                var yystate: UInt = 0
                yyl: while true {
                    switch yystate {
                    case 0:
                        yych = yyinput[yycursor]
                        yycursor += 1
                        switch yych {
                        case 0x27:
                            yystate = 3
                            continue yyl
                        case 0x2D:
                            yystate = 4
                            continue yyl
                        case 0x2F:
                            yystate = 5
                            continue yyl
                        default:
                            yystate = 1
                            continue yyl
                        }
                    case 1:
                        yystate = 2
                        continue yyl
                    case 2:
                        yyoutput.append(yyinput[llmarker])
                        continue loop
                    case 3:
                        yych = yyinput[yycursor]
                        yycursor += 1
                        switch yych {
                        case 0x27:
                            yystate = 6
                            continue yyl
                        default:
                            yystate = 3
                            continue yyl
                        }
                    case 4:
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x2D:
                            yycursor += 1
                            yystate = 8
                            continue yyl
                        default:
                            yystate = 2
                            continue yyl
                        }
                    case 5:
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x2A:
                            yycursor += 1
                            yystate = 10
                            continue yyl
                        default:
                            yystate = 2
                            continue yyl
                        }
                    case 6:
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x27:
                            yycursor += 1
                            yystate = 3
                            continue yyl
                        default:
                            yystate = 7
                            continue yyl
                        }
                    case 7:
                        while llmarker < yycursor {
                            yyoutput.append(yyinput[llmarker])
                            llmarker += 1
                        }
                        continue loop
                    case 8:
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x00:
                            fallthrough
                        case 0x0A:
                            fallthrough
                        case 0x0D:
                            yystate = 9
                            continue yyl
                        default:
                            yycursor += 1
                            yystate = 8
                            continue yyl
                        }
                    case 9:
                        continue loop
                    case 10:
                        yych = yyinput[yycursor]
                        yycursor += 1
                        switch yych {
                        case 0x2A:
                            yystate = 11
                            continue yyl
                        default:
                            yystate = 10
                            continue yyl
                        }
                    case 11:
                        yych = yyinput[yycursor]
                        yycursor += 1
                        switch yych {
                        case 0x2F:
                            yystate = 12
                            continue yyl
                        default:
                            yystate = 10
                            continue yyl
                        }
                    case 12:
                        continue loop
                    default: fatalError("internal lexer error")
                    }
                }
            }
            yyoutput.append(0)
            return String(cString: yyoutput, encoding: .utf8) ?? ""
        }
    }
    
    /// Trims empty lines and trailing whitespace outside string literals.
    ///
    /// This function preserves line breaks and whitespace inside string literals,
    /// removing only redundant empty lines and trailing whitespace outside literals.
    ///
    /// The implementation of this function is generated using
    /// [`re2swift`](https://re2c.org/manual/manual_swift.html)
    /// from the following parsing template:
    ///
    /// ```swift
    /// @inline(__always)
    /// func trimmingLines() -> String {
    ///     withCString {
    ///         let yyinput = $0
    ///         let yylimit = strlen($0)
    ///         var yyoutput = [CChar]()
    ///         var yycursor = 0
    ///         var yymarker = 0
    ///         loop: while yycursor < yylimit {
    ///             var llmarker = yycursor/*!re2c
    ///             re2c:define:YYCTYPE   = "CChar";
    ///             re2c:yyfill:enable    = 0;
    ///
    ///             "'" ([^'] | "''")* "'" {
    ///                 while llmarker < yycursor {
    ///                     yyoutput.append(yyinput[llmarker])
    ///                     llmarker += 1
    ///                 }
    ///                 continue loop }
    ///
    ///             [ \t]* "\x00" {
    ///                 continue loop }
    ///
    ///             [ \t]* "\n\x00" {
    ///                 continue loop }
    ///
    ///             [ \t\n]* "\n"+ {
    ///                 if llmarker > 0 && yycursor < yylimit {
    ///                     yyoutput.append(0x0A)
    ///                 }
    ///                 continue loop }
    ///
    ///             [^] {
    ///                 yyoutput.append(yyinput[llmarker])
    ///                 continue loop }
    ///         */}
    ///         yyoutput.append(0)
    ///         return String(
    ///             cString: yyoutput,
    ///              encoding: .utf8
    ///          ) ?? ""
    ///     }
    /// }
    /// ```
    @inline(__always)
    func trimmingLines() -> String {
        withCString {
            let yyinput = $0
            let yylimit = strlen($0)
            var yyoutput = [CChar]()
            var yycursor = 0
            var yymarker = 0
            loop: while yycursor < yylimit {
                var llmarker = yycursor
                var yych: CChar = 0
                var yyaccept: UInt = 0
                var yystate: UInt = 0
                yyl: while true {
                    switch yystate {
                    case 0:
                        yych = yyinput[yycursor]
                        yycursor += 1
                        switch yych {
                        case 0x00:
                            yystate = 1
                            continue yyl
                        case 0x09:
                            fallthrough
                        case 0x20:
                            yystate = 4
                            continue yyl
                        case 0x0A:
                            yystate = 5
                            continue yyl
                        case 0x27:
                            yystate = 7
                            continue yyl
                        default:
                            yystate = 2
                            continue yyl
                        }
                    case 1:
                        continue loop
                    case 2:
                        yystate = 3
                        continue yyl
                    case 3:
                        yyoutput.append(yyinput[llmarker])
                        continue loop
                    case 4:
                        yyaccept = 0
                        yymarker = yycursor
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x00:
                            fallthrough
                        case 0x09...0x0A:
                            fallthrough
                        case 0x20:
                            yystate = 9
                            continue yyl
                        default:
                            yystate = 3
                            continue yyl
                        }
                    case 5:
                        yyaccept = 1
                        yymarker = yycursor
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x00:
                            yycursor += 1
                            yystate = 11
                            continue yyl
                        case 0x09...0x0A:
                            fallthrough
                        case 0x20:
                            yystate = 13
                            continue yyl
                        default:
                            yystate = 6
                            continue yyl
                        }
                    case 6:
                        if llmarker > 0 && yycursor < yylimit {
                            yyoutput.append(0x0A)
                        }
                        continue loop
                    case 7:
                        yych = yyinput[yycursor]
                        yycursor += 1
                        switch yych {
                        case 0x27:
                            yystate = 15
                            continue yyl
                        default:
                            yystate = 7
                            continue yyl
                        }
                    case 8:
                        yych = yyinput[yycursor]
                        yystate = 9
                        continue yyl
                    case 9:
                        switch yych {
                        case 0x00:
                            yycursor += 1
                            yystate = 1
                            continue yyl
                        case 0x09:
                            fallthrough
                        case 0x20:
                            yycursor += 1
                            yystate = 8
                            continue yyl
                        case 0x0A:
                            yycursor += 1
                            yystate = 5
                            continue yyl
                        default:
                            yystate = 10
                            continue yyl
                        }
                    case 10:
                        yycursor = yymarker
                        if yyaccept == 0 {
                            yystate = 3
                            continue yyl
                        } else {
                            yystate = 6
                            continue yyl
                        }
                    case 11:
                        continue loop
                    case 12:
                        yych = yyinput[yycursor]
                        yystate = 13
                        continue yyl
                    case 13:
                        switch yych {
                        case 0x09:
                            fallthrough
                        case 0x20:
                            yycursor += 1
                            yystate = 12
                            continue yyl
                        case 0x0A:
                            yycursor += 1
                            yystate = 14
                            continue yyl
                        default:
                            yystate = 10
                            continue yyl
                        }
                    case 14:
                        yyaccept = 1
                        yymarker = yycursor
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x09:
                            fallthrough
                        case 0x20:
                            yycursor += 1
                            yystate = 12
                            continue yyl
                        case 0x0A:
                            yycursor += 1
                            yystate = 14
                            continue yyl
                        default:
                            yystate = 6
                            continue yyl
                        }
                    case 15:
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x27:
                            yycursor += 1
                            yystate = 7
                            continue yyl
                        default:
                            yystate = 16
                            continue yyl
                        }
                    case 16:
                        while llmarker < yycursor {
                            yyoutput.append(yyinput[llmarker])
                            llmarker += 1
                        }
                        continue loop
                    default: fatalError("internal lexer error")
                    }
                }
            }
            yyoutput.append(0)
            return String(
                cString: yyoutput,
                encoding: .utf8
            ) ?? ""
        }
    }
    
    /// Splits the SQL script into individual statements by semicolons.
    ///
    /// This function preserves string literals (enclosed in single quotes),
    /// and treats `BEGIN...END` blocks as single nested statements, preventing
    /// splitting inside these blocks. Statements are split only at semicolons
    /// outside string literals and `BEGIN...END` blocks.
    ///
    /// The implementation of this function is generated using
    /// [`re2swift`](https://re2c.org/manual/manual_swift.html)
    /// from the following parsing template:
    ///
    /// ```swift
    /// @inline(__always)
    /// func splitStatements() -> [String] {
    ///     withCString {
    ///         let yyinput = $0
    ///         let yylimit = strlen($0)
    ///         var yyranges = [Range<Int>]()
    ///         var yycursor = 0
    ///         var yymarker = 0
    ///         var yynesting = 0
    ///         var yystart = 0
    ///         var yyend = 0
    ///         loop: while yycursor < yylimit {/*!re2c
    ///             re2c:define:YYCTYPE   = "CChar";
    ///             re2c:yyfill:enable    = 0;
    ///
    ///             "'" ( [^'] | "''" )* "'" {
    ///                 yyend = yycursor
    ///                 continue loop }
    ///
    ///             'BEGIN' {
    ///                 yynesting += 1
    ///                 yyend = yycursor
    ///                 continue loop }
    ///
    ///             'END' {
    ///                 if yynesting > 0 {
    ///                     yynesting -= 1
    ///                 }
    ///                 yyend = yycursor
    ///                 continue loop }
    ///
    ///             ";" [ \t]* "\n"* {
    ///                 if yynesting == 0 {
    ///                     if yystart < yyend {
    ///                         yyranges.append(yystart..<yyend)
    ///                     }
    ///                     yystart = yycursor
    ///                     continue loop
    ///                 } else {
    ///                     continue loop
    ///                 }}
    ///
    ///             [^] {
    ///                 yyend = yycursor
    ///                 continue loop }
    ///         */}
    ///         if yystart < yyend {
    ///             yyranges.append(yystart..<yyend)
    ///         }
    ///         return yyranges.map { range in
    ///             let buffer = UnsafeBufferPointer<CChar>(
    ///                 start: yyinput.advanced(by: range.lowerBound),
    ///                 count: range.count
    ///             )
    ///             let array = Array(buffer) + [0]
    ///             return String(cString: array, encoding: .utf8) ?? ""
    ///         }
    ///     }
    /// }
    /// ```
    @inline(__always)
    func splitStatements() -> [String] {
        withCString {
            let yyinput = $0
            let yylimit = strlen($0)
            var yyranges = [Range<Int>]()
            var yycursor = 0
            var yymarker = 0
            var yynesting = 0
            var yystart = 0
            var yyend = 0
            loop: while yycursor < yylimit {
                var yych: CChar = 0
                var yystate: UInt = 0
                yyl: while true {
                    switch yystate {
                    case 0:
                        yych = yyinput[yycursor]
                        yycursor += 1
                        switch yych {
                        case 0x27:
                            yystate = 3
                            continue yyl
                        case 0x3B:
                            yystate = 4
                            continue yyl
                        case 0x42:
                            fallthrough
                        case 0x62:
                            yystate = 6
                            continue yyl
                        case 0x45:
                            fallthrough
                        case 0x65:
                            yystate = 7
                            continue yyl
                        default:
                            yystate = 1
                            continue yyl
                        }
                    case 1:
                        yystate = 2
                        continue yyl
                    case 2:
                        yyend = yycursor
                        continue loop
                    case 3:
                        yych = yyinput[yycursor]
                        yycursor += 1
                        switch yych {
                        case 0x27:
                            yystate = 8
                            continue yyl
                        default:
                            yystate = 3
                            continue yyl
                        }
                    case 4:
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x09:
                            fallthrough
                        case 0x20:
                            yycursor += 1
                            yystate = 4
                            continue yyl
                        case 0x0A:
                            yycursor += 1
                            yystate = 10
                            continue yyl
                        default:
                            yystate = 5
                            continue yyl
                        }
                    case 5:
                        if yynesting == 0 {
                            if yystart < yyend {
                                yyranges.append(yystart..<yyend)
                            }
                            yystart = yycursor
                            continue loop
                        } else {
                            continue loop
                        }
                    case 6:
                        yymarker = yycursor
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x45:
                            fallthrough
                        case 0x65:
                            yycursor += 1
                            yystate = 11
                            continue yyl
                        default:
                            yystate = 2
                            continue yyl
                        }
                    case 7:
                        yymarker = yycursor
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x4E:
                            fallthrough
                        case 0x6E:
                            yycursor += 1
                            yystate = 13
                            continue yyl
                        default:
                            yystate = 2
                            continue yyl
                        }
                    case 8:
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x27:
                            yycursor += 1
                            yystate = 3
                            continue yyl
                        default:
                            yystate = 9
                            continue yyl
                        }
                    case 9:
                        yyend = yycursor
                        continue loop
                    case 10:
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x0A:
                            yycursor += 1
                            yystate = 10
                            continue yyl
                        default:
                            yystate = 5
                            continue yyl
                        }
                    case 11:
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x47:
                            fallthrough
                        case 0x67:
                            yycursor += 1
                            yystate = 14
                            continue yyl
                        default:
                            yystate = 12
                            continue yyl
                        }
                    case 12:
                        yycursor = yymarker
                        yystate = 2
                        continue yyl
                    case 13:
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x44:
                            fallthrough
                        case 0x64:
                            yycursor += 1
                            yystate = 15
                            continue yyl
                        default:
                            yystate = 12
                            continue yyl
                        }
                    case 14:
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x49:
                            fallthrough
                        case 0x69:
                            yycursor += 1
                            yystate = 16
                            continue yyl
                        default:
                            yystate = 12
                            continue yyl
                        }
                    case 15:
                        if yynesting > 0 {
                            yynesting -= 1
                        }
                        yyend = yycursor
                        continue loop
                    case 16:
                        yych = yyinput[yycursor]
                        switch yych {
                        case 0x4E:
                            fallthrough
                        case 0x6E:
                            yycursor += 1
                            yystate = 17
                            continue yyl
                        default:
                            yystate = 12
                            continue yyl
                        }
                    case 17:
                        yynesting += 1
                        yyend = yycursor
                        continue loop
                    default: fatalError("internal lexer error")
                    }
                }
            }
            if yystart < yyend {
                yyranges.append(yystart..<yyend)
            }
            return yyranges.map { range in
                let buffer = UnsafeBufferPointer<CChar>(
                    start: yyinput.advanced(by: range.lowerBound),
                    count: range.count
                )
                let array = Array(buffer) + [0]
                return String(cString: array, encoding: .utf8) ?? ""
            }
        }
    }
}
