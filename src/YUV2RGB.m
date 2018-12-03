% Input a YUV output a RGB
function out = YUV2RGB(in)
 Y = in(:,:,1);
 U = in(:,:,2);
 V = in(:,:,3);
 
 R = Y + 1.14 * V;
 G = Y - 0.395 * U - 0.581 * V;
 B = Y + 2.033 * U;
 
 out = cat(3,R,G,B);
end