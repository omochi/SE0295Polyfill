import Foundation
import SwiftTypeReader

func join(_ lines: [String], _ separator: String = "\n") -> String {
    lines.joined(separator: separator)
}

func pascalCase(_ str: String) -> String {
    if str.isEmpty { return str }

    let i0 = str.startIndex
    var head = String(str[i0])
    head = head.uppercased()

    let i1 = str.index(after: i0)
    let tail = str[i1...]

    return head + tail
}

func codingKey(_ c: CaseElement) -> String {
    pascalCase(c.name) + "CodingKey"
}

func label(of assoc: AssociatedValue, _ index: Int) -> String {
    if let name = assoc.name {
        return name
    } else {
        return "_\(index)"
    }
}

func pattern(of assocs: [AssociatedValue]) -> String {
    if assocs.isEmpty {
        return ""
    }

    var str = "("

    str += assocs.enumerated().map { (i, assoc) in
        var str = ""
        if let name = assoc.name {
            str += "\(name): "
        }
        str += "let \(label(of: assoc, i))"
        return str
    }.joined(separator: ", ")

    str += ")"

    return str
}

func construct(_ c: CaseElement) -> String {
    var str = ".\(c.name)"

    if !c.associatedValues.isEmpty {
        str += "("

        str += c.associatedValues.enumerated().map { (i, v) in
            var str = ""
            if let name = v.name {
                str += "\(name): "
            }
            str += "\(label(of: v, i))"
            return str
        }.joined(separator: ", ")

        str += ")"
    }

    return str
}

func unwrapOptional(_ type: SType) throws -> (type: SType, isWrapped: Bool) {
    var isWrapped = false
    var type = type
    if let st = type.struct,
       st.name == "Optional",
       try st.genericArguments().count > 0
    {
        type = try st.genericArguments()[0]
        isWrapped = true
    }
    return (type: type, isWrapped: isWrapped)
}
