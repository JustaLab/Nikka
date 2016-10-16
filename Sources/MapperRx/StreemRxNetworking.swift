/* This software is licensed under the Apache 2 license, quoted below.
 
 Copyright 2016 Emilien Stremsdoerfer <emstre@gmail.com>
 Licensed under the Apache License, Version 2.0 (the "License"); you may not
 use this file except in compliance with the License. You may obtain a copy of
 the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 License for the specific language governing permissions and limitations under
 the License.
 */

import Foundation
import RxSwift
import Mapper

public extension Request{
    
    func response<T: Mappable>() -> Observable<T>{
        return Observable.create{ observer in
            self.responseObject({ (response:Response<T>) in
                switch response.result{
                case .success(let value):
                    observer.onNext(value)
                    observer.on(.completed)
                case .failure(let error):
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
    
    func response<T: Mappable>(rootKey:String? = nil) -> Observable<[T]>{
        return Observable.create{ observer in
            self.responseArray(rootKey:rootKey, { (response:Response<[T]>) in
                switch response.result{
                case .success(let values):
                    observer.onNext(values)
                    observer.on(.completed)
                case .failure(let error):
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
}