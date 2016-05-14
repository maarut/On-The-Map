//
//  Array+utils.swift
//  On The Map
//
//  Created by Maarut Chandegra on 14/05/2016.
//  Copyright © 2016 Maarut Chandegra. All rights reserved.
//

extension SequenceType
{
    func first(@noescape comparator: (Self.Generator.Element) -> Bool) -> Self.Generator.Element?
    {
        for e in self {
            if comparator(e) { return e }
        }
        return nil
    }
}

