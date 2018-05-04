a = zeros(252,11);
n = 0;
for i = 1:28
    for j = 1:3
        for k = 1:3
            i
            j
            k
            [va,vb,vc,vd,ve,vf,vg,vh,vi,vj,vk]=process(i,j,k);
            n = n + 1;
            a(n,:) = [va,vb,vc,vd,ve,vf,vg,vh,vi,vj,vk];
        end
    end
end
xlswrite('data0.xlsx',a)
