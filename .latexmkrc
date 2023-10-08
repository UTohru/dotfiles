#!/usr/bin/env perl
$latex		= 'uplatex %O -kanji=utf8 -syntex=1 -file-line-error -halt-on-error %S';
$latex_silent	= 'uplatex %O -kanji=utf8 -syntex=1 -file-line-error -halt-on-error -interaction=batchmode %S';
$biber		= 'biber %O --bblencoding=utf8 -u -U --output_safechars %B';
#$bibtex		= 'upbibtex %O %B';
$bibtex		= 'pbibtex %O %B';
$dvipdf		= 'dvipdfmx %O -o %D %S';
# $makeindex	= 'mendex %O -o %D %S';
$max_repeat	= 7;
$pdf_mode	= 3; # 3: dvi->pdf
# $aux_dir	= 'log/';
$out_dir	= 'output/';

$bibtex_use		= 2; # monitor bibliography
#$pvc_view_file_via_temporary = 0;

$preview_mode = 1; # same -pv option

# wsl
if(-e '/proc/sys/fs/binfmt_misc/WSLInterop'){
	$pdf_previewer = "/mnt/c/Users/" . $ENV{WIN_USER} . "/AppData/Local/SumatraPDF/SumatraPDF.exe -reuse-instance %S"; 
}else{
	$pdf_previewer = "/usr/bin/evince";
}

# clean :  latexmk -c
