"---------------------------------------------------------------------------"
""
"Name : File Sorter "
"Description : A file arrangement which move the files to the matched directories "
""
"---------------------------------------------------------------------------"

$gsFilePath = "C:\MY\COMIC\"
$gsDirPath = "C:\MY\"
$gsUnclassifiedDirPath = "C:\MY\UNDONE\"


FUNCTION Debug 
{
    $sText = "#"

    for ($i=0; $i -lt $args.length; $i++) {
        $sText += "," + $args[$i]
    }
    
    $sText
}

# -------- 1. get the tokens from the directory list ----------

# store the directory list into array
$gasDirList = Get-ChildItem $gsDirPath | 
   Where-Object { $_.PSIsContainer} | 
   Foreach-Object {$_.Name}

$gasTokenList = @(0) * $gasDirList.length
   
# show the list
for ($i=0; $i -lt $gasDirList.length; $i++) 
{
    # "[" + $i + "]" + $gasDirList[$i]
    
    $sText = $gasDirList[$i]
    $iBegin = $sText.IndexOf("[")
    
    if ($iBegin -eq 0)
    {
        $iBegin = $iBegin + 1
    }
    
    $iTemp1 = $sText.IndexOf("(") - 1
    $iTemp2 = $sText.IndexOf("]") - 1
    
    # Debug $i $iBegin $iTemp1 $iTemp2
    
    if ($iTemp1 -gt 0 -AND $iTemp1 -lt $iTemp2)
    {
        $iEnd = $iTemp1  # ex. [AA(BB)] -> AA
    }
    else
    {
        $iEnd = $iTemp2 # ex. [AA] -> AA
    }

    if ($iBegin -gt 0 -AND $iEnd -gt $iBegin)
    {
        $gasTokenList[$i] = $sText.Substring($iBegin, $iEnd).Trim() # ex. [AA] -> AA
    }
    else
    {
        $gasTokenList[$i] = $sText.Trim() # ex. AA -> AA
    }

    "" + $gasTokenList[$i] + " <-- " + $sText
}
       
"## " + $gasDirList.length + " directories (" + $gasTokenList.length + " tokens" + ") in " + $gsDirPath

# -------- 2. pick each file from the file list to the match directories  ----------


FUNCTION pickFile
{
    $sFileName = $args[0]
    $iBegin = -1
    $iTarget = 0
    
    "---------> " + $sFileName
    
    for ($i=0; $i -lt $gasTokenList.length; $i++) 
    {
        $iBegin = $sFileName.IndexOf($gasTokenList[$i])
        
        if ($iBegin -gt -1 -AND $gasTokenList[$i] -ne "COMIC")
        {
            $iTarget = $i
            break
        }
    }
    
    $sSourcePath = $gsFilePath + $sFileName
    
    if ($iBegin -gt -1) # copy to each matched directory
    {
        " match: " + $gasTokenList[$iTarget] + " in " + $sFileName

        $sDestPath = $gsDirPath + $gasDirList[$iTarget]
        
        # Debug "Move " $sSourcePath $sDestPath 

        # The source path needs to add the escape charthater but destination path does not. (I don't get it.)
        MOVE-Item -Path $sSourcePath.replace('[', '`[').replace(']', '`]') -Destination $sDestPath # -Force
        
        #REMOVE-ITEM -Path $sSourcePath.replace('[', '`[').replace(']', '`]')
    }
    else # copy to the specific unmatched directory
    {
        MOVE-Item -Path $sSourcePath.replace('[', '`[').replace(']', '`]') -Destination $gsUnclassifiedDirPath
    }
}

# store the file list into array
$gasFileList = Get-ChildItem $gsFilePath | 
   Where-Object { -not $_.PSIsContainer} | 
   Foreach-Object {$_.Name}
  
"There exists " + $gasFileList.length + " files in " + $gsFilePath

# show the list
for ($i=0; $i -lt $gasFileList.length; $i++) 
{
    # "[" + $i + "]" + $gasFileList[$i]
    
    pickFile $gasFileList[$i]
}


"----------------------- End of the powershell script -----------------------"

FUNCTION Test
{
    # [regex]::Escape() -> no fucking use

    # Move-Item c:\scripts\test.zip c:\test
    $str = "C:\MY\COMIC\1[DA HOOTCH].cbz"
    $str = [regex]::Escape($str) # -> no use
    #$str.replace('[', '`[').replace(']', '`]') | Out-File -Encoding UTF8 "temp.txt" 
    #COPY-Item -Path (Get-Content "temp.txt") -Destination 'C:\MY\'

    
    #$sSourcePath.replace('[', '`[').replace(']', '`]') | Out-File -Encoding UTF8 #"tempSource.txt" 
    #"----->" +  $sSourcePath
    #$sDestPath.replace('[', '`[').replace(']', '`]') | Out-File -Encoding UTF8 "tempDest.txt" 
    #COPY-Item -Path (Get-Content "tempSource.txt") -Destination (Get-Content "tempDest.txt")
    
    #MOVE-Item -Path "C:\MY\tempww.txt" -Destination "C:\MY\COMIC\"
}

