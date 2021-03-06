## -------------- MAIN ---------------- ##

# Drive
$drive = 'C:'
$LastLogFileName = 'LAST_LOG.txt'
$FullLogFileName = 'FULL_LOG.txt'

# Folders
#$SourceRootFolder = $drive+'\'+'BUILD\Microsoft\ES-Community-Content\MSDN'
$SourceRootFolder = $drive+'\'+'BUILD\MINITEL\MSDN\10\es-es\Articles\Originals'

#$DestArticleFolder = $drive+'\'+'BUILD\Microsoft\ES-Community-Content\Tools\Converted\MSDN'
$DestArticleFolder = $SourceRootFolder+'\Converted'

#$SourceMetaFiles = $DestArticleFolder+'\Articles\Config Files'
$NewDestFolder = ""
$NewDestFile=""

# LogFIles in Dest Folder
$LastLogFile = $DestArticleFolder + '\'+$LastLogFileName
$FullLogFile = $DestArticleFolder + '\'+$FullLogFileName

$FilesByTitle = $DestArticleFolder + '\Articles.txt'


echo '.' >> $LastLogFile
echo '################## START ##################'>> $LastLogFile
echo ((Get-Date -Format u) + '-- Start Conversion')  >> $LastLogFile
echo '.' >> $LastLogFile

cd $drive
cd \
cd $SourceRootFolder

if (Test-Path -Path $SourceRootFolder -eq $false )
{
echo ('-- ERROR: SourceRootFolder does not exsit - '+$SourceRootFolder)  >> $LastLogFile
echo '-- Exiting'  >> $LastLogFile

Exit-PSSession;
}

## ------- for each doc file
Get-ChildItem -Path $SourceRootFolder -Filter *.docx | ForEach-Object { 
		
		
		echo ('-- Working on File: '+($_.FullName)) >> $LastLogFile

		
		## read articles' title from Word
		$wd = New-Object -ComObject Word.Application
		$wd.Visible = $false
		$objDocument = $wd.Documents.Open($_.FullName)
		$paras = $objDocument.Paragraphs
		$DocTitle = $paras.First.Range.Text
		$objDocument.Close()
		$wd.Quit()
		$wd = $null
		
		#set destination folder and filename equal to Filename of article 
		$NewDestFolder=$DestArticleFolder+"\"+$_.BaseName
		$NewDestFile=$NewDestFolder+"\"+$_.BaseName+".md"
		
		## create folder with same name as the file (minus extension)
		New-Item -ItemType directory -Path $NewDestFolder
		
		## copy Config files 
		#Copy-Item -Path ($SourceMetaFiles+'\*.*') -Destination ($NewDestFolder) 

		## copy the word file in proper subfolder
		Copy-Item -Path ($_.FullName) -Destination ($NewDestFolder) 
		
		## edit MASTERTOC.XML file to replace filename with new one
		#$myXMLFile = $NewDestFolder+'\mastertoc.xml'
		#[xml] $xml = gc $myXMLFile
		#$xml.masterToc.files.file = (($NewDestFolder)+'\'+$_.Name)
		#$xml.Save($myXMLFile)

		## edit helpConfig.xml file to replace Title & ProjectName
		#$myXMLFile = $NewDestFolder+'\helpConfig.xml'
		#[xml] $xml = gc $myXMLFile
		## title i should read into the Doc file
		#$xml.options.title = ($DocTitle)
		#$xml.options.ProjectName = $_.BaseName.ToString()
		#$xml.Save($myXMLFile)
				
		## enter the new folder and call the pandoc converter 
		Set-Location -Path $NewDestFolder
		
		#Invoke-Command '.\pandoc -f docx -t markdown -o test.md C:\BUILD\CommunityContent\MSDN\10\it-it\Articles\HxS\TA_1511001_gmricci_GitflowAndNuget2\GitflowAndNugetPart2.docx --extract-media=./media'
		Invoke-Expression -Command ('pandoc -f docx -t markdown -o "'+$NewDestFile+'" "'+$_.FullName+'" --extract-media=./img/')
		
		#if the .md file was generated
		if(Test-Path ($NewDestFile))
		{
		#the .md file exists, all good
		echo ('OK - File created - '+($NewDestFile))  >> $LastLogFile
		
		#write the converted file into the list with the title to connect it to the MSDN AssetID
		echo ($DocTitle+'|'+$NewDestFile+'|'+$NewDestFolder) >> $FilesByTitle
		
		#move it to the main folder
		#Move-Item -Path ($NewDestFolder+'\output\'+$_.BaseName+'.hxs') -Destination $DestArticleFolder -Force -WarningAction Inquire
		#Remove-Item -Path ($NewDestFolder+'\output') -Recurse -Force
		## delete the original file as it's inside the subfolder and that also signals everythign OK on this file
		#Remove-Item -Path ($_.FullName)
		}
		else
		{
		write ('Error on file '+($NewDestFile))
		echo ('Error on file '+($NewDestFile))  >> $LastLogFile
		}
	}
	

echo ((Get-Date -Format u) + '-- End Conversion')  >> $LastLogFile
echo '################## END ##################'>> $LastLogFile
echo '.' >> $LastLogFile

exit

