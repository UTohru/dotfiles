#!/usr/bin/env perl
$latex		= 'uplatex %O -kanji=utf8 -syntex=1 -file-line-error -halt-on-error %S';
$latex_silent	= 'uplatex %O -kanji=utf8 -syntex=1 -file-line-error -halt-on-error -interaction=batchmode %S';
$biber		= 'biber %O --bblencoding=utf-8 -u -U --output_safechars %B';
#$bibtex		= 'upbibtex %O %B';
$bibtex		= 'pbibtex %O %B';
$dvipdf		= 'dvipdfmx %O -o %D %S';
# $makeindex	= 'mendex %O -o %D %S';
$max_repeat	= 7;
$pdf_mode	= 3; # .dvi -> .pdf

# ordpdf not rm
#$pvc_view_file_via_temporary = 0;

# wsl
if(-e '/proc/sys/fs/binfmt_misc/WSLInterop'){
	$pdf_previewer = "/mnt/c/Users/" . $ENV{WIN_USER} . "/AppData/Local/SumatraPDF/SumatraPDF.exe"; 
}else{
	$pdf_previewer = "/usr/bin/evince";
}

# clean :  latexmk -c
