%==========================================================================
% 输入序列名称 码率 编解码及性能文本的路径信息和文件名提取对应性能指标
%==========================================================================
function seqInfo = ExtractInfo(sequence,rate,cfgPath,eninfoName,deinfoName,errorinfoName)
    seqInfo = cell(1,19);
    seqInfo{1} = sequence;
    seqInfo{2} = rate;
    
    encoder = [cfgPath,eninfoName];
    fidin = fopen(encoder,'r');
    Gbitstream = 0;
    Abitstream = 0;
    Rbitstream = 0;
    Tbitstream = 0;
    while ~feof(fidin)
        tline = fgetl(fidin);% read the text file by rows
        if strncmp(tline,'positions bitstream',15)
            Gbit = regexp(tline,'\d*\.?\d*','match');
            Gbitstream = Gbitstream + str2num(Gbit{1});% 针对某些序列有多个slice划分的情况处理
            seqInfo{5} = num2str(Gbitstream*8);% encoder info中单位为B，但是表格中bits
            continue;
        end
        if strncmp(tline,'colors bitstream',15)
            Abit = regexp(tline,'\d*\.?\d*','match');
            Abitstream = Abitstream + str2num(Abit{1});% 针对某些序列有多个slice划分的情况处理
            seqInfo{6} = num2str(Abitstream*8);
            continue;
        end
        if strncmp(tline,'reflectances bitstream',20)
            Rbit = regexp(tline,'\d*\.?\d*','match');
            Rbitstream = Rbitstream + str2num(Rbit{1});% 针对某些序列有多个slice划分的情况处理
            seqInfo{7} = num2str(Rbitstream*8);
            continue;
        end        
        if strncmp(tline,'Total bitstream',13)
            Tbit = regexp(tline,'\d*\.?\d*','match');
            Tbitstream = Tbitstream + str2num(Tbit{1});
            seqInfo{4} = num2str(Tbitstream*8);
            continue;
        end
        if strncmp(tline,'Processing time (user)',20)
            Etime = regexp(tline,'\d*\.?\d*','match');
            seqInfo(18) = Etime(1);
            continue;
        end
    end
    
    decoder = [cfgPath,deinfoName];
    fidin1 = fopen(decoder,'r');
    while ~feof(fidin1)
        tline = fgetl(fidin1);
        if strncmp(tline,'Processing time (user)',20)
            Dtime = regexp(tline,'\d*\.?\d*','match');
            seqInfo(19) = Dtime(1);
            continue;
        end
    end    
    
    
    pcerror = [cfgPath,errorinfoName];
    fidin2 = fopen(pcerror,'r');
    while ~feof(fidin2)
        tline = fgetl(fidin2);
        if strfind(tline,'the scaling ratio')
            outPoints = regexp(tline,'\d*\.?\d*','match');
            seqInfo(3) = outPoints(2);
            continue;
        end
        if strfind(tline,'mseF,PSNR (p2point)')
            Gpsnr = regexp(tline,'\d*\.?\d*','match');
            if length(Gpsnr) == 1 % 如果几何无损那么这里数据就是空的，需要处理否则程序中断
                Gpsnr = {'Inf'};
            end
            seqInfo(8) = Gpsnr(end);
            continue;
        end
        if strfind(tline,'mseF,PSNR (p2plane)')
            Gpsnr2 = regexp(tline,'\d*\.?\d*','match');
            if length(Gpsnr2) == 1 % 如果几何无损那么这里数据就是空的，需要处理否则程序中断
                Gpsnr2 = {'Inf'};
            end
            seqInfo(9) = Gpsnr2(end);
            continue;
        end
        if  strfind(tline,'h.c[0],PSNRF') % 因为‘c[0],PSNRF’也可以匹配到这种情况，所以需要先判断这个才可以，否则数据会被‘c[0],PSNRF’截胡
            hLumapsnr = regexp(tline,'\d*\.?\d*','match');
            if length(hLumapsnr) == 1
                hLumapsnr = {'Inf'};
            end
            seqInfo(14) = hLumapsnr(end);
            continue;
        end
        if strfind(tline,'h.c[1],PSNRF')
            hCbpsnr = regexp(tline,'\d*\.?\d*','match');
            if length(hCbpsnr) == 1
                hCbpsnr = {'Inf'};
            end
            seqInfo(15) = hCbpsnr(end);
            continue;
        end
        if strfind(tline,'h.c[2],PSNRF')
            hCrpsnr = regexp(tline,'\d*\.?\d*','match');
            if length(hCrpsnr) == 1
                hCrpsnr = {'Inf'};
            end
            seqInfo(16) = hCrpsnr(end);
            continue;
        end
        if strfind(tline,'h.r,PSNR   F')
            hRpsnr = regexp(tline,'\d*\.?\d*','match');
            if isempty(hRpsnr)
                hRpsnr = {'Inf'};
            end
            seqInfo(17) = hRpsnr(end);
            continue;
        end        
        if strfind(tline,'c[0],PSNRF')
            Lumapsnr = regexp(tline,'\d*\.?\d*','match');
            if length(Lumapsnr) == 1
                Lumapsnr = {'Inf'};
            end
            seqInfo(10) = Lumapsnr(end);
            continue;
        end
        if strfind(tline,'c[1],PSNRF')
            Cbpsnr = regexp(tline,'\d*\.?\d*','match');
            if length(Cbpsnr) == 1
                Cbpsnr = {'Inf'};
            end
            seqInfo(11) = Cbpsnr(end);
            continue;
        end
        if strfind(tline,'c[2],PSNRF')
            Crpsnr = regexp(tline,'\d*\.?\d*','match');
            if length(Crpsnr) == 1
                Crpsnr = {'Inf'};
            end
            seqInfo(12) = Crpsnr(end);
            continue;
        end
        if strfind(tline,'r,PSNR   F')
            Rpsnr = regexp(tline,'\d*\.?\d*','match');
            if isempty(Rpsnr)
                Rpsnr ={'Inf'};
            end
            seqInfo(13) = Rpsnr(end);
            continue;
        end        
    end
    fclose('all');
end