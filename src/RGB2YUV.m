% Input a RGB array, output a YUV array
function out = RGB2YUV(in)
 R = in(:,:,1);
 G = in(:,:,2);
 B = in(:,:,3);
 
 Y = 0.299*R + 0.587*G + 0.114*B;
 U = 0.492 * (B - Y);
 V = 0.877 * (R - Y);
 
 out = cat(3,Y,U,V);
end