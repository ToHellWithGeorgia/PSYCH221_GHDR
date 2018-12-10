function b = rgb2bayer(a)
    for n=1:3
        b(:,:,n)=kron(a(:,:,n),uint8([1:2;2:3]==n));
    end
    out = double(b)/255;
    b = out(:,:,3)+out(:,:,1)+out(:,:,2);
end