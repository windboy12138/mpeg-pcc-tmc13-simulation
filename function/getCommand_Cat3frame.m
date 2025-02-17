function command = getCommand_Cat3frame(codeName,cfgPath,plyPath,sequence,plyName,firstFrame,frameCount,nowIndex,infoName,mode)
switch mode
    case 'encode'
        command = [codeName,'.exe'...
                   ' -c ',cfgPath,'encoder.cfg'...
                   ' --uncompressedDataPath=',plyPath,sequence,plyName,'%d.ply'...
                   ' --firstFrameNum=',firstFrame...
                   ' --frameCount=',frameCount...
                   ' --compressedStreamPath=./Cat3-cache/compressed.bin'...
                   ' --reconstructedDataPath=./Cat3-cache/reconstruct-%d.ply'...
                   ' >',cfgPath,infoName];
    case 'decode'
        command = [codeName,'.exe'...
                   ' -c ',cfgPath,'decoder.cfg'...
                   ' --compressedStreamPath=./Cat3-cache/compressed.bin'...
                   ' --reconstructedDataPath=./Cat3-cache/decoded-%d.ply'...
                   ' >',cfgPath,infoName];
    case 'pcerror'
        command = [codeName...
                   ' -a ',plyPath,sequence,plyName,'.ply'...
                   ' -b ','./Cat3-cache/decoded-',nowIndex,'.ply'...
                   ' -c 1'...
                   ' --lidar=1'... % ����reflectance
                   ' --dropdups=2'...
                   ' --neighborsProc=1'...
                   ' --hausdorff=1'...% ����hausdorff psnr
                   ' >>',cfgPath,infoName];
end