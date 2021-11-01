%==========================================================================
% ������������ ���� ����뼰�����ı���·����Ϣ���ļ�����ȡ��Ӧ����ָ��
%==========================================================================
function seqInfo = ExtractInfo_Cat3_frame(sequence,rate,cfgPath,eninfoName,deinfoName,errorinfoName)
    seqInfo = cell(1,19);
    seqInfo{1} = sequence;
    seqInfo{2} = rate;
    rPsnrCheck = ones(1500,1);
    
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
            Gbitstream = Gbitstream + str2num(Gbit{1});% ���ĳЩ�����ж��slice���ֵ��������
            seqInfo{5} = num2str(Gbitstream*8);% encoder info�е�λΪB�����Ǳ����bits
            continue;
        end
        if strncmp(tline,'colors bitstream',15)
            Abit = regexp(tline,'\d*\.?\d*','match');
            Abitstream = Abitstream + str2num(Abit{1});% ���ĳЩ�����ж��slice���ֵ��������
            seqInfo{6} = num2str(Abitstream*8);
            continue;
        end
        if strncmp(tline,'reflectances bitstream',20)
            Rbit = regexp(tline,'\d*\.?\d*','match');
            Rbitstream = Rbitstream + str2num(Rbit{1});% ���ĳЩ�����ж��slice���ֵ��������
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
    rPsnrTotal = 0;
    hrPsnrTotal = 0;
    outPointsTotal = 0;
    frameCount = 0;
    duplicatePoints = 0;
    while ~feof(fidin2)
        tline = fgetl(fidin2);
        %=========================================
        if strfind(tline,'points with same coordinates found and averaged')
            duplicate = regexp(tline,'\d*\.?\d*','match');
            nextline = fgetl(fidin2);
            if strfind(nextline,'Reading file 2 done.')
                duplicatePoints = str2num(duplicate{1});
            end
        end
        %=========================================
        if strfind(tline,'the scaling ratio')
            outPoints = regexp(tline,'\d*\.?\d*','match');
            outPointsTotal = outPointsTotal + str2num(outPoints{2}) + duplicatePoints;
            frameCount = frameCount + 1;
            seqInfo(3) ={num2str(outPointsTotal)};
            continue;
        end
        if strfind(tline,'mseF,PSNR (p2point)')
            Gpsnr = regexp(tline,'\d*\.?\d*','match');
            if length(Gpsnr) == 1 % �������������ô�������ݾ��ǿյģ���Ҫ�����������ж�
                Gpsnr = {'Inf'};
            end
            seqInfo(8) = Gpsnr(end);
            continue;
        end
        if strfind(tline,'mseF,PSNR (p2plane)')
            Gpsnr2 = regexp(tline,'\d*\.?\d*','match');
            if length(Gpsnr2) == 1 % �������������ô�������ݾ��ǿյģ���Ҫ�����������ж�
                Gpsnr2 = {'Inf'};
            end
            seqInfo(9) = Gpsnr2(end);
            continue;
        end
        if  strfind(tline,'h.c[0],PSNRF') % ��Ϊ��c[0],PSNRF��Ҳ����ƥ�䵽���������������Ҫ���ж�����ſ��ԣ��������ݻᱻ��c[0],PSNRF���غ�
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
            hrPsnrTotal = hrPsnrTotal + str2double(hRpsnr{2});
            if isempty(hRpsnr)
                hRpsnr = {'Inf'};
            else
                hRpsnr{2} = num2str(hrPsnrTotal);
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
            rPsnrCheck(frameCount) = str2double(Rpsnr{1});
            rPsnrTotal = rPsnrTotal + str2double(Rpsnr{1});
            if isempty(Rpsnr)
                Rpsnr ={'Inf'};
            else
                Rpsnr = {num2str(rPsnrTotal)};
            end
            seqInfo(13) = Rpsnr(end);
            continue;
        end        
    end
    rPsnrFinal = str2double(seqInfo{13}) / frameCount;
    hrPsnrFinal = str2double(seqInfo{17}) / frameCount;
%     seqInfo{13} = num2str(rPsnrFinal);
    seqInfo{13} = round(rPsnrFinal, 6); % ���־���
%     seqInfo{17} = num2str(hrPsnrFinal);
    seqInfo{17} = round(hrPsnrFinal, 6);
    fclose('all');
end