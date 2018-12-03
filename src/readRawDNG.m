function out = readRawDNG(filename)
    warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning
    t = Tiff(filename,'r');
    out = read(t);
    close(t);
end