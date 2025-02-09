//
//  AcornsLessons.swift
//  AcornsMobilePlayerApp
//
//  Created by Dan Harvey on 7/25/15.
//  Copyright (c) 2015 Dan Harvey. All rights reserved.
//

import Foundation

class AcornsLessons: NSObject  {
    let fileManager = FileManager.default
    
    var error: NSError?
    var errorMessage = "";

    /** Find the path to the application documents directory */
    func applicationDocumentsDirectory() -> String! {
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray
        if paths.count > 0 {
            return paths.object(at: 0) as? String
        }
        else {
            return nil
        }
    }
    
    /** Find the path to the Resources directory */
    func applicationResourceDirectory() -> String! {
        let path = Bundle.main.resourcePath! + "/sampleLessons"
        return path
    }
    
    /** Find the path to the application Library/Caches directory */
    func applicationCachesDirectory() -> String! {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true)
        let basePath = paths.first as String?
        return basePath! as String
    }
    
    /** Find the path to the appliation Inbox directory */
    func applicationInboxDirectory() -> String {
        let documents = applicationDocumentsDirectory()
        return (documents! as NSString).appendingPathComponent("Inbox")
    }

    /** Get path to directory containing uncompressed lesson */
    func lessonDirectory(_ path: String) ->String {
        let caches = applicationCachesDirectory() as String
        return (caches as NSString).appendingPathComponent(path)
    }
    
    /** Get a directory listing of an application directory */
    func directoryListing(_ path: String) -> [String] {
        let documentsArray: [String]?
        do {
            documentsArray = try fileManager.contentsOfDirectory(atPath: path)
        } catch let error1 as NSError {
            error = error1
            documentsArray = nil
        }
        if documentsArray == nil { return [] as [String]}
        return (documentsArray)!
    }
    
    /** Get lesson name by removing directory path and file extension */
    func getLessonName(_ path: String) ->String! {
        let theFileName = (path as NSString).lastPathComponent
        let nameWithoutExtension = (theFileName as NSString).deletingPathExtension
        return nameWithoutExtension
    }
    
    /** Determine if path defines a directory */
    func isDirectory(_ directory: String!) ->Bool {
        let attribs: NSDictionary?
        do {
            attribs = try fileManager.attributesOfItem(
                        atPath: directory) as NSDictionary
        } catch let error1 as NSError {
            error = error1
            attribs = nil
        }
        
        if let fileattribs = attribs {
            let type = fileattribs["NSFileType"] as? String
            return type == "NSFileTypeDirectory"
        }
        return false;
    }
    
    /** Output error codes relating to failed file operations */
    func error(_ fileName: String)
    {
        print(NSString(format:"Failed to remove file %@: %@", fileName, error!.localizedDescription))
    }
    
    func deleteLessonFromCache(_ fileName: String) {
        let directory = lessonDirectory(fileName as String)
        let htmlFilePath = directory + ".html"

        if fileManager.fileExists(atPath: directory)
        {
            do
            {
                try fileManager.removeItem(atPath: directory)
            } catch let error1 as NSError { error = error1; error(directory) }
        }
        
        
        if fileManager.fileExists(atPath: htmlFilePath)
        {
            do {
                try fileManager.removeItem(atPath: htmlFilePath)
            } catch let error1 as NSError { error = error1; error(htmlFilePath) }
        }
    }
    
    func deleteLessonFromGallery(_ fileName: String) {
        let compressedName = fileName + ".acorns"
        let documentDirectory = applicationDocumentsDirectory()
        let acornsPath = (documentDirectory! as NSString).appendingPathComponent(compressedName)
        do {
            try fileManager.removeItem(atPath: acornsPath)
        } catch let error1 as NSError { error = error1; error(acornsPath) }
        //deleteLessonFromCache(fileName)
    }
    
    /** Function to determine if an ACORNS lesson is already uncompressed to the cache directory */
    func lessonExist(_ fileName: String) -> Bool {
        let directory = lessonDirectory(fileName as String)
        let htmlFilePath = directory + ".html"

        let exists = isDirectory(directory) && fileManager.fileExists(atPath: htmlFilePath)
        if exists {  return true }
        else      {  deleteLessonFromCache(fileName) }
        
        return false
    }
    
    /** Function to get URL for displaying an ACORNS lesson in the UIWebView */
    func lessonURL(_ file: String)->URLRequest {
        let directory = lessonDirectory(file)
        let webName = directory + ".html"
        let url = URL(fileURLWithPath: webName)
        let request = URLRequest(url: url)
        return request
    }
    
    func printTextToLog(_ webName: String!)
    {
        do {
            let data = try String(contentsOfFile: webName, encoding: .utf8)
            let myStrings = data.components(separatedBy: .newlines)
            let text = myStrings.joined(separator: "\n")
            print("\(text)")
        } catch {
            print(error)
        }
    }

    /** Function to unzip a compressed archive 
      *
      * Note: to zip a file use the following two statements
      *       let zipPath = globalFileStrucure.stringByAppendingPathComponent("zipfile.zip")
      *       data.writeToFile(zipPath, options: nil, error: &error)
      */
    func unzip(_ file: String, destination: String) ->Bool
    {
        let sourceDirectory = applicationDocumentsDirectory()
        let sourceFilePath = (sourceDirectory! as NSString).appendingPathComponent(file)
        let result = SSZipArchive.unzipFile(atPath: sourceFilePath /*oringal zipPath*/, toDestination: destination /* original globalFileStructure */)
        print(result)
        return result
    }
    
    func getWarningMessage() ->String
    {
        return errorMessage
    }

    /** Read a text file, so a global search and replace, and write the edited file back
     *     This is needed to accommodate renamed Apple archives
     */
    func editFile(path: String, from: String, to: String) -> Bool
    {
        if from == to
        {
            return true
        }
        var source = ""
        do
        {
            source = try String(contentsOfFile: path, encoding: .utf8)
        } catch let error as NSError { print(error); return false }
        
        source = source.replacingOccurrences(of: from, with: to)
        
        do
        {
            try source.write(toFile: path, atomically: true, encoding: .utf8)
        } catch let error as NSError { print(error); return false }

        return true;
    }

    /** Function to unzip and rename unzipped files if necessary
      * Note: because duplicate downloaded files have their name changed by Apple, the uncompressed file names need to be changed to match
      */
    func unzipAndRename(_ lessonName: String) ->String
    {
        let temp = applicationCachesDirectory()
        let tempDirectory = (temp! as NSString).appendingPathComponent("_" + lessonName)
        let badArchive = "Illegal archive"
        let badSize = "Illegal archive size"
        let badContent = "Illegal archive content"
        let badName = "Illegal archive name"
        let badEdit = "Couldn't edit file"
        let badDuplicate = "Lesson already downloaded"
        
        try? fileManager.removeItem(atPath: tempDirectory)
        try? fileManager.createDirectory(atPath: tempDirectory, withIntermediateDirectories:false)
        
        let fileName = lessonName + ".acorns"
        let result = unzip(fileName, destination: tempDirectory)
        if !result
        {
            NSLog(badArchive)
            return badArchive        }
        
       let files = directoryListing(tempDirectory);
       let fileCount = files.count
       if (fileCount != 2)
        {
            NSLog(badSize);
            return badSize
        }
        

        var oldLessonName = (files[0] as NSString).deletingPathExtension
        var fileExtension = (files[0] as NSString).pathExtension
        if !(lessonName.hasPrefix(oldLessonName) && (fileExtension.isEmpty  || fileExtension == "html"))
        {
            NSLog(badName)
            return badName
        }

        var oldFilePath = (tempDirectory as NSString).appendingPathComponent(files[0])
        var newFileName = lessonName
        var newFilePath = (temp! as NSString).appendingPathComponent(newFileName)
        
        var dir = false;
        if isDirectory(oldFilePath) {
           dir = true;
        }
        else {
            newFileName += "." + fileExtension
            newFilePath += "." + fileExtension
            if !editFile(path: oldFilePath, from: oldLessonName, to: lessonName)
            {
                NSLog (badEdit)
                return badEdit
            }
        }
        
        var badMove = "Couldn't move " + oldFilePath + " to " + newFilePath
        if fileManager.fileExists(atPath: newFilePath)
        {
            NSLog(badDuplicate)
            return badDuplicate
        }

        do {
            try fileManager.moveItem(atPath: oldFilePath, toPath: newFilePath)
        } catch {
            NSLog(badMove)
            return badMove;
        }
        
        oldLessonName = (files[1] as NSString).deletingPathExtension
        fileExtension = (files[1] as NSString).pathExtension
        if !(lessonName.hasPrefix(oldLessonName) && (fileExtension.isEmpty  || fileExtension == "html"))
        {
            NSLog(badName)
            return badName
        }

        oldFilePath = (tempDirectory as NSString).appendingPathComponent(files[1])
        newFileName = lessonName
        newFilePath = (temp! as NSString).appendingPathComponent(newFileName)

        if isDirectory(oldFilePath)
        {
            if dir {
                NSLog(badContent)
                return badContent;
            }
        }
        else
        {
            if !dir {
                NSLog (badContent)
                return badContent;
            }
            newFileName += "." + fileExtension
            newFilePath += "." + fileExtension
            if !editFile(path: oldFilePath, from: oldLessonName, to: lessonName)
            {
                NSLog (badEdit)
                return badEdit
            }
        }
        
        if fileManager.fileExists(atPath: newFilePath)
        {
            NSLog(badDuplicate)
            return badDuplicate
        }
                
        badMove = "Couldn't move " + oldFilePath + " to " + newFilePath
        do {
            try fileManager.moveItem(atPath: oldFilePath, toPath: newFilePath)
        } catch {
            NSLog(badMove)
            return badMove
        }
        try? fileManager.removeItem(atPath: tempDirectory)
        return ""
    }

    
    /** Insert a lesson into the mutable array */
    func insertLesson(_ data: NSMutableArray, item: String) {
        var index = 0
        if data.count > 0 {
            for i in (0..<(data.count-1)).reversed() {
                let value = data.object(at: i) as! String
                let result = value.localizedCompare(item)
                if result == ComparisonResult.orderedAscending { break }
                index = i
            }
        }
        data.insert(item, at: index)
        
    }
    
    /** Purge lesson gallery cache of lessons no longer in documents */
    func purgeGallery() {
        let temp = applicationCachesDirectory()
        let documents = applicationDocumentsDirectory()

        let list = directoryListing(temp!)
        var lessonName: String
        for i in 0 ..< list.count {
            lessonName = list[i]
            _ = (temp! as NSString).appendingPathComponent(lessonName)
            if lessonName.hasSuffix(".html")  {
                lessonName = getLessonName(lessonName)
                let uncompressedName = (lessonName as NSString).appendingPathExtension("acorns")
                let lessonDocumentPath = (documents! as NSString).appendingPathComponent(uncompressedName!)
                if !fileManager.fileExists(atPath: lessonDocumentPath) {
                    deleteLessonFromCache(lessonName)
                }
            }
        }
    }
    
    fileprivate func directoryExistsAtPath(_ path: String) -> Bool
    {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
  
    /* If file has not been copied into the application inbox, do it now */
    func copyLesson(_ fromURL: URL)
    {
        var from = fromURL.path
        let exist = from.contains("Inbox")
        if exist
        {
            NSLog("file already copied")
            return
        }
        
        if from.hasSuffix(".zip")
        {
            let count = from.count
            from = String(from.prefix(count-4))
        }
        
 
        let lessonName = getLessonName(from) + ".acorns"
        NSLog("Lesson name = " + lessonName)
        
        let documents = applicationDocumentsDirectory()
        let to = (documents! as NSString).appendingPathComponent(lessonName)
        let toURL = NSURL.fileURL(withPath: to)
        
        if fileManager.fileExists(atPath: to)
        {
            NSLog("file is already in documents")
            return
        }
        NSLog("file needs copying")

    
        let result = fromURL.startAccessingSecurityScopedResource()
        var data: Data
        if result
        {
            do
            {
                data = try Data(contentsOf: fromURL)
                try data.write(to:toURL)
             } catch(let error) { print(error) }
        }
        fromURL.stopAccessingSecurityScopedResource()
        if !fileManager.fileExists(atPath: to)
        {
          NSLog("file copy failed")
          return
        }
        
        NSLog("copied sucessfully")
    }
    
    /** Find and unzip lessons in the Inbox directory */
    func processInboxDirectory(_ objects: NSMutableArray) {
        let inbox = applicationInboxDirectory()
        let documents = applicationDocumentsDirectory()
 
        let list = directoryListing(inbox)
        for item in (list as [String])
        {
            let lessonName = getLessonName(item)
            let theFileName = (item as NSString).lastPathComponent
            let compressedName = lessonName! + ".acorns"
            if lessonExist(lessonName!)
            {
                deleteLessonFromGallery(lessonName!)
                objects.remove(lessonName!)
            }

            let from = (inbox as NSString).appendingPathComponent(theFileName)
            let to = (documents! as NSString).appendingPathComponent(compressedName)
            do {
                try fileManager.moveItem(atPath: from, toPath: to)
 
            } catch let error1 as NSError
            {
                error = error1; error(from)
            }
            
            let result = unzipAndRename(lessonName!)
            errorMessage = result
            if result.isEmpty
            {
                do {
                    try fileManager.removeItem(atPath: compressedName)
                } catch let error1 as NSError { error = error1; error(compressedName) }
            }
            objects.insert(lessonName!, at: 0)
        }  // end of for item
    }
 
    func findTestLessons() {
        let resources = applicationResourceDirectory()
        let documents = applicationDocumentsDirectory()
        let list = directoryListing(resources!)
        
        for item in list as [String] {
            if item.hasSuffix(".acorns") {
                let to = (documents! as NSString).appendingPathComponent(item)
                let exists = fileManager.fileExists(atPath: to)
                if exists {
                    NSLog("Lesson exists %@", item)
                    continue
                }
 
                let from = (resources! as NSString).appendingPathComponent(item)
                _ = fileManager.fileExists(atPath: from)
                do {
                try fileManager.copyItem(atPath: from, toPath: to)
                } catch let error1 as NSError {
                    error = error1
                    error(from)
                }
            }
        }
    }
    
    /** Find all of the acorns lessons in the application sandbox documents directory */
    func findLessons() ->NSMutableArray! {
        let objects = NSMutableArray()
        let documents = applicationDocumentsDirectory()
        let list = directoryListing(documents!)
        
        purgeGallery() // Delete lessons no longer in the gallery from the cache
        for item in list as [String] {
            if item.hasSuffix(".acorns") {
                let lessonName = getLessonName(item)
                insertLesson(objects, item: lessonName!)
                if !lessonExist(lessonName!)
                {
                    NSLog("Lesson name = " + lessonName! + " doesn't exist")
                    let result = unzipAndRename(lessonName!)
                    errorMessage = result
                    if !result.isEmpty
                    {
                         do
                         {
                             try fileManager.removeItem(atPath: item)
                         } catch let error1 as NSError { error = error1; error(item) }
                     }
                }
            }
        }
        processInboxDirectory(objects)
        NSLog("Documents = %@", documents!)
        return objects
    }   // end of findLessons()
    
    
}   // End of class
