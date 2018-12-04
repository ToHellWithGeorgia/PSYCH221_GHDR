% Input a YUV output a RGB
function out = YUV2RGB(in)
 Y = in(:,:,1);
 U = in(:,:,2);
 V = in(:,:,3);
 
 R = min(Y + 1.14 * V, 1);
 G = min(Y - 0.395 * U - 0.581 * V, 1);
 B = min(Y + 2.033 * U, 1);
 
 out = cat(3,R,G,B);
end