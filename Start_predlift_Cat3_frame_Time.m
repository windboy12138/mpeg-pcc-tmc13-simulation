%======================================================================
% lossless nearlossless attr (CW CY)采用pred transform;
% lossy attr (C1 C2)采用lift transform
% mode = ('encode' 'decode' 'pcerror')
%======================================================================
% !!!程序名codeName不要包含文件类型后缀(.exe)
% !!!初次使用时将BreakPoint设置为空
% 如果遇到特殊情况运行中断 将BreakPoint设置为中断时的处理信息可从断点继续
% BreakPoint = {'TransformTpye','Condition','Sequence','Rate'};
% TransformType = {'octree-predlift','trisoup-predlift'};
% Conditon = {'lossless-geom-lossy-attrs','lossy-geom-lossy-attrs'...
%             'lossless-geom-lossless-attrs','lossless-geom-nearlossless-attrs'}
%             C1 C2 CW CY
%======================================================================
%% For Determine Parametes
clc,clear;
codeNameArray = {'anchor_12','adaptive_quant_for_point'};
% BreakPoint = {'octree-predlift','lossless-geom-nearlossless-attrs','ford_03_q1mm','r02'}; 
BreakPoint = {}; 
onlyExtractInfo = 1; % 1:only extract info; 0:encode and extract info;

sequenceName = {'ford_01_q1mm','ford_02_q1mm','ford_03_q1mm'...
                'qnxadas-junction-approach','qnxadas-junction-exit','qnxadas-motorway-join','qnxadas-navigating-bends'};
plyNameArray = {'/Ford_01_vox1mm-','/Ford_02_vox1mm-','/Ford_03_vox1mm-','/0000','/0000','/000','/000'};
firstFrameNumArray = {'100','100','200','1','1','1','1'};
frameCountArray = {'1500','1500','1500','74','74','500','300'};
TransformType = {'octree-predlift'};
TestCondition = {'lossless-geom-nearlossless-attrs'}; %CY
Rate = {'r01' 'r02' 'r03' 'r04' 'r05' 'r06'};% low QP range
% Rate = {'r04','r05','r06','r07','r08','r09'}; % high QP range
% Rate = {'r01','r02','r03','r04','r05','r06','r07','r08','r09'}; % full QP range
plyPath = '../PlyFiles/';

%% For predlift Transform
if ~onlyExtractInfo
    for i =1 : length(TransformType)
        transform = TransformType{i};

        if ~isempty(BreakPoint)
            if ~strcmp(transform,BreakPoint{1})
                continue;
            end
        end

        Realcondition = TestCondition;
        %==================================================
        for j = 1 : length(Realcondition)
            condition = Realcondition{j};

            if ~isempty(BreakPoint)
                if ~strcmp(condition,BreakPoint{2})
                    continue;
                end
            end
            % 对不同的condition匹配不同的测试码率 全无损设置一个伪码率后续再进行处理
            if strcmp(condition,'lossless-geom-lossless-attrs')
                BitRate = {'lossless'};%赋一个伪码率以便进入码率的循环体 后续再判断处理掉
            else if strcmp(condition,'lossless-geom-nearlossless-attrs')
                BitRate = Rate;
                BitRate(end) =[];
                else
                    BitRate = Rate;
                end
            end
            %======================================================================
            for k = 1 : length(sequenceName)
                sequence = sequenceName{k};
                firstFrameNum = firstFrameNumArray{k};
                frameCount = frameCountArray{k};
                plyName = plyNameArray{k};
                if ~isempty(BreakPoint)
                    if ~strcmp(sequence,BreakPoint{3})
                        continue;
                    end
                end  
                for m = 1 : length(BitRate)
                    rate = BitRate{m};

                    if ~isempty(BreakPoint)
                        if ~strcmp(rate,BreakPoint{4})
                            continue;
                        end
                        if strcmp(rate,BreakPoint{4})
                            BreakPoint = {};% 已经恢复到断点位置 后续不再continue
                        end
                    end

                    % 对全无损的伪码率进行处理
                    if length(BitRate)==1
                        cfgPath = ['../cfg/',transform,'/',condition,'/',sequence,'/'];
                    else
                        cfgPath = ['../cfg/',transform,'/',condition,'/',sequence,'/',rate,'/'];
                    end
                    %===========================
                    for C = 1 : length(codeNameArray)
                        codeName = codeNameArray{C};
                        disp(['NowProcessing:  ',cfgPath,'  ',codeName]);
                        system(['echo ',datestr(now,31),'  ',cfgPath,'  ',codeName,' >>encodeProcess.txt']);% 记录意外中断时的断点位置
                        eninfoName = [codeName,'_encoder.txt'];
                        deinfoName = [codeName,'_decoder.txt'];
                        errorinfoName = [codeName,'_pcerror.txt'];
                        encodeCommand = getCommand_Cat3frame(codeName,cfgPath,plyPath,sequence,plyName,firstFrameNum,frameCount,'0',eninfoName,'encode');
                        status = system(encodeCommand);
                        while(status ~= 0)
                            disp(['encode:  ',num2str(status)]);
                            status = system(encodeCommand);
                        end
                        decodeCommand = getCommand_Cat3frame(codeName,cfgPath,plyPath,sequence,plyName,firstFrameNum,frameCount,'0',deinfoName,'decode');
                        status = system(decodeCommand);
                        while (status ~= 0)
                            disp(['decode:  ',num2str(status)]);
                            status = system(decodeCommand);
                        end

                        % 如果存在上次残余的性能文件信息则删除
                        if exist([cfgPath,errorinfoName],'file') ~= 0
                            delete([cfgPath,errorinfoName]);
                        end

                        for index = 1 : str2num(frameCount)
                            % 检查 pcerror 的command是否计算hausdorff psnr
                            nowIndex = num2str(index - 1 + str2num(firstFrameNum));
                            decodeIndex = num2str(index - 1);
                            plyNameFull = [plyName,nowIndex];
                            pcerrorCommand = getCommand_Cat3frame('pcerror.exe',cfgPath,plyPath,sequence,plyNameFull,firstFrameNum,frameCount,decodeIndex,errorinfoName,'pcerror');
                            status = system(pcerrorCommand);
                            while (status ~= 0)
                                disp(['pcerror:  ',num2str(status)]);
                                status = system(pcerrorCommand);
                            end                        
                        end

                    end
                end
            end
        end
    end
    msgbox('Encode Mission Completed!');
end
%% For Extract Information
xlsxType = {'name','rate','output points','Total Bitstream Bits','Geometry','Color','Reflectance'...
            'D1','D2','End to End Luma','Cb','Cr','Reflectance','Hausdoff Luma','Cb','Cr'...
            'Reflectance','encode time','decode time'};
for C = 1 : length(codeNameArray)
    codeName = codeNameArray{C};
    for i =1 : length(TransformType)
        transform = TransformType{i};
        %==================================================
        for j = 1 : length(TestCondition)
            condition = TestCondition{j};
            sheetName = getSheetName(condition);
            xlswrite([codeName,'_',transform,'-cat3.xlsx'],xlsxType,sheetName,'A1'); % 创建一个带表头的condition sheet
            sequencesInfo = [];

            % 对不同的condition匹配不同的测试码率 全无损设置一个伪码率后续再进行处理
            if strcmp(condition,'lossless-geom-lossless-attrs')
                BitRate = {'lossless'};%赋一个伪码率以便进入码率的循环体 后续再判断处理掉
            else if strcmp(condition,'lossless-geom-nearlossless-attrs')
                BitRate = Rate;
                BitRate(end) =[];
                else
                    BitRate = Rate;
                end
            end
            %======================================================================
            for k = 1 : length(sequenceName)
                sequence = sequenceName{k};

                for m = 1 : length(BitRate)
                    rate = BitRate{m};                
                    % 对全无损的伪码率进行处理
                    if length(BitRate)==1
                        cfgPath = ['../cfg/',transform,'/',condition,'/',sequence,'/'];
                    else
                        cfgPath = ['../cfg/',transform,'/',condition,'/',sequence,'/',rate,'/'];
                    end
                    %===========================
                    disp(['NowProcessing:  ',cfgPath]);
                    eninfoName = [codeName,'_encoder.txt'];
                    deinfoName = [codeName,'_decoder.txt'];
                    errorinfoName = [codeName,'_pcerror.txt'];
                    seqInfo = ExtractInfo_Cat3_frame(sequence,rate,cfgPath,eninfoName,deinfoName,errorinfoName);
                    sequencesInfo = [sequencesInfo;seqInfo];% 整合condition下所有sequence rate的性能信息
                end
            end
            xlswrite([codeName,'_',transform,'-cat3.xlsx'],sequencesInfo,sheetName,'A2'); % 写入一个condition下的所有信息
        end
    end
end
msgbox('Extract Mission Completed!');