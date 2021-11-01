function sheetName = getSheetName(condition)
    switch condition
        case 'lossless-geom-lossless-attrs'
            sheetName = 'CW losslG,losslA';
        case 'lossless-geom-nearlossless-attrs'
            sheetName = 'CY losslG,nearllA';
        case 'lossless-geom-lossy-attrs'
            sheetName = 'C1 losslG,lossyA';
        case 'lossy-geom-lossy-attrs'
            sheetName = 'C2 lossyG,lossyA';
    end
end