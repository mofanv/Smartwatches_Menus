function [va,vb,vc,vd,ve,vf,vg,vh,vi,vj,vk]=process(p,s,m)
%任务完成时间va,进入应用次数vb,菜单内停留时间vc,应用内停留时间vd
%菜单内正滑动次数ve,菜单内反滑动次数vf,菜单内总滑动次数vg
%应用内正滑动次数vh,应用内反滑动次数vi,应用内总滑动次数vj
%点击成功率vk

strPath = strcat('P',num2str(p),'_S',num2str(s),'_M',num2str(m),'.csv');
d = csvread(strPath);

x1 = d(:,1);
x2 = d(:,2);
x6 = d(:,6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%任务完成时间Va 的计算
a = zeros(5,1);
for n = 1:5
   num1 = 8000;   %800 = 任务
   num2 = num1 + n;
   k = 1;
    for i = 1:length(x1)
        %找到一个任务的开始
        if i > k
            if x1(i) == num2
                for j = (i+1):length(x1)
                    %找到下一个名字一致的任务
                    if x1(j) == num2
                        time1 = x6(i+1);
                        time2 = x6(j-1);
                        time = time2 - time1;
                        if abs(time) >= 500
                            time = 15;
                        end
                        a(n) = time;
                        k = j;
                        break;
                    end                
                end
            end
        end
    end
end
va = mean(a);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%进入应用个数 Vb 的计算
enterAppNum = 0;
for i = 1:length(x1)
    if x2(i) == 0 && x1(i) ~= 0 && x1(i) ~= 7000 %7000 = 主菜单
        enterAppNum = enterAppNum + 1;
    end  
end
vb = enterAppNum;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%在菜单及应用中的停留时间Vc, Vd 的计算
point1 = zeros(length(x1),1);
point2 = zeros(length(x1),1);
for i = 1:length(x1)
    %判断当前处于菜单还是应用中.1为在菜单中,2为在应用中
    if x2(i) ~= 0 && i > 1
            point1(i) = point1(i-1);   
    else if x2(i) == 0 && x1(i) == 7000;
            point1(i) = 1;
        else if x2(i) == 0 && x1(i) ~= 7000;
                point1(i) = 2; 
            end
        end 
    end
    %判断是否在任务中.1为在，0为不在
    if (x2(i) ~= 998 && x2(i) ~= 999) && i > 1
        point2(i) = point2(i-1);
    else if x2(i) == 998;
            point2(i) = 1;
        else if x2(i) ==999;
                point2(i) = 0;
            end
        end
    end
end

%计算任务中，在菜单或应用里的停留时间
timeMenu = 0;
timeApp = 0;
k = 1;
for i = 1:length(x1)
    if i >= k %从上一次位置开始
        %从任务开始时
        if point2(i) == 1 && point1(i) ~= 0 && x2(i) == 998; 
            timeStart = x6(i+1);
            for j = i:length(x1)-1 
                if x2(j+1) == 999 || point1(j) ~= point1(j-1)
                    timeEnd = x6(j);
                    k = j;
                    break;
                end
            end
            time = timeEnd - timeStart;
            if abs(time) > 500
                time = 10;
            end
            %判断是菜单中的停留，还是应用中的停留
            if point1(i) == 1;
                timeMenu = timeMenu + time;
            else if point1(i) == 2;
                    timeApp = timeApp + time;
                end
            end
        end
        %从进入菜单或应用时
        if i >= 2
            if point2(i) == 1 && point1(i) ~= point1(i-1); 
                timeStart = x6(i);
                for j = i:length(x1)-1 
                    if x2(j+1) == 999
                        timeEnd = x6(j);
                        k = j;
                        break;
                    end
                    if point1(j) ~= point1(j+1)
                        timeEnd = x6(j-1);
                        k = j;
                        break;
                    end
                end
                time = timeEnd - timeStart;
                if abs(time) > 500
                    time = 10;
                end
                %判断是菜单中的停留，还是应用中的停留
                if point1(i) == 1;
                    timeMenu = timeMenu + time;
                else if point1(i) == 2;
                        timeApp = timeApp + time;
                    end
                end
            end
        end
    end
end
vc = timeMenu;
vd = timeApp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%菜单内正滑动次数ve,菜单内反滑动次数vf,菜单内总滑动次数vg 的计算
%应用内正滑动次数vh,应用内反滑动次数vi,应用内总滑动次数vj 的计算
swipeLeftNum_Menu = 0;
swipeRightNum_Menu = 0;
swipeLeftNum_App = 0;
swipeRightNum_App = 0;
for i = 1:length(x1)
    if point1(i) == 1 && point2(i) == 1 && x1(i) == +1
        swipeLeftNum_Menu = swipeLeftNum_Menu + 1;
    else if point1(i) == 1 && point2(i) == 1 && x1(i) == -1;
        swipeRightNum_Menu = swipeRightNum_Menu + 1;
    else if point1(i) == 2 && point2(i) == 1 && x1(i) == +1;
        swipeLeftNum_App = swipeLeftNum_App + 1;
    else if point1(i) == 2 && point2(i) == 1 && x1(i) == -1;
        swipeRightNum_App = swipeRightNum_App + 1;
        end
        end
        end
    end
end
ve = swipeLeftNum_Menu;
vf = swipeRightNum_Menu;
vg = ve + vf;
vh = swipeLeftNum_App;
vi = swipeRightNum_App;
vj = vh + vi;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%点击成功率vk 的计算

tipNum = 0;
for i = 1:length(x1)
    if point2(i) == 1 && x1(i) == 0
        tipNum = tipNum + 1;
    end
end
vk = vb/tipNum;
