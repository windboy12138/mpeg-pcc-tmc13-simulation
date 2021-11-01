set codeName=adaptive_quant_for_point
set plyname=(facade_00009_vox12)

set cur_dir=%cd%
set ply_dir=./PlyFiles
set rate=(r01 r05)
set CY=cfg/octree-predlift/lossless-geom-nearlossless-attrs

for %%P in %plyname% do (
	for %%R in %rate% do (
		%codeName%.exe -c %cd%/%CY%/%%P/%%R/encoder.cfg --uncompressedDataPath=%ply_dir%/%%P.ply --compressedStreamPath=compressed.bin --reconstructedDataPath=reconstruct_%%R.ply
		%codeName%.exe -c %cd%/%CY%/%%P/%%R/decoder.cfg --compressedStreamPath=compressed.bin --reconstructedDataPath=decoded_%%R.ply
		rem pcerror.exe -a %ply_dir%/%%P.ply -b decoded.ply -c 1 >%cur_dir%/%CY%/%%P/%%R/%codeName%_pcerror.txt
)
)
pause