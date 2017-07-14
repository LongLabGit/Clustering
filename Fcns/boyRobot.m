function boyRobot(or)
col=[1,1,1];
if or==1%anatomical space
    line(9-[2.5,6.5],9.5*[1,1],'color',col,'linewidth',5)
    line(9-[4.5,6.5],9.5*[1,1],'color',col,'linewidth',5)
    line(9-[4.5,6.5],10.5*[1,1],'color',col,'linewidth',5)

    line(9-[1,1]*2.5,[0,9.5],'color',col,'linewidth',5)
    line(9-[1,1]*6.5,[9.5,10.5],'color',col,'linewidth',5)
    line(9-[1,1]*4.5,[10.5,15.5],'color',col,'linewidth',5)
else%probe
    line([2.5,6.5],9.5*[1,1],'color',col,'linewidth',5)
    line([4.5,6.5],9.5*[1,1],'color',col,'linewidth',5)
    line([4.5,6.5],10.5*[1,1],'color',col,'linewidth',5)

    line([1,1]*2.5,[0,9.5],'color',col,'linewidth',5)
    line([1,1]*6.5,[9.5,10.5],'color',col,'linewidth',5)
    line([1,1]*4.5,[10.5,15.5],'color',col,'linewidth',5)
end