burst_iset_raw = {};
for i = 1:8
    fn = strcat('burst_', num2str(i), '.png');
    input = imread(strcat('iset/', fn));
    burst_iset_raw{i} = rgb2bayer(input);
end
