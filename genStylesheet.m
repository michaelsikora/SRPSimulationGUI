function css = genStylesheet(COMPUTER)
%GENSTYLESHEET Default stylesheet for GUI simulation

%%%% Set Style Attributes
colors{1} = '71d1f1'; % blue
colors{2} = '71f1c1'; % mint
colors{3} = '315171'; % dark blue
colors{4} = '317151'; % forest green
colors{5} = 'ffa151'; % orange
colors{6} = '333333'; % grey
colors{7} = '0033a0'; % Wildcat Blue
colors{8} = '2c2a29'; % Wildcat Black
colors{9} = '1897d4'; % Light Blue
% colora = colors{1+round((length(colors)-1)*rand(1))}; 
colora = colors{9};
css.rgbcolora = hex2dec([colora(1:2); colora(3:4); colora(5:6)]);
colorb = 'fafafa';
css.rgbcolorb = hex2dec([colorb(1:2); colorb(3:4); colorb(5:6)]);

css.width = 900; css.height = 600;
css.size = [css.width css.height css.width css.height];

%%%% SideMenu Styling
css.sideMenuTop = css.height-10;
css.textOffset = 4;
css.itemOffset = 30;
css.border = 16;
css.padding = 4;
css.boxTop = css.sideMenuTop;

css.sidemenu1 = {'indselect','varlist','guiopts'};
css.sidemenu2 = {'output','srpsim','aftersrp','guiopts'};

css.HorizontalAlignment = 'Left'; 
css.FontWeight = 'bold';
css.FontSize = 8; 
if COMPUTER == 0
    css.FontName = 'Arial';
elseif COMPUTER == 1
    css.FontName = 'KaiTi';
end

end

