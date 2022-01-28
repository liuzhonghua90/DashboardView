# DashboardView
绘制仪表盘

/**
 大致思路：
 在页面上绘制CALayer，这个CALayer上由两部分组层，一个外环CAShapeLayer，另一个刻度环CAShapeLayer,绘制完成后添加到CALayer上，最后将CALayer再添加到self.layer上
 1.绘制外环CAShapeLayer(带有渐变色)
 1.1先绘制一个普通的CAShapeLayer
 a.绘制CAShapeLayer需要通过UIBezierPath来实现路径（点和线）的连接，具体参数：中心点、半径、起点、终点、顺时针
 b.path设置好后，将其赋值给CAShapeLayer属性path，由此一个图形就出来了
 1.2在普通的CAShapeLayer上实现渐变色
 a.也是需要再创建一个CALayer，然后在其基础上创建两个CAGradientLayer来实现渐变色，设置其属性渐变颜色，
 b.之后将两个创建好的CAGradientLayer添加在CALayer上
 c.最后CALayer再添加到self.layer上
 2.刻度环CAShapeLayer
 2.1创建CAShapeLayer刻度，添加到最开始的CALayer上
 2.2利用UIBezierPath将起来的线在CAShapeLayer串联
 
 3.绘制文字
 3.通过CGContextRef执行上下文，将所有点通过drawReact方法显示出来
 总体来说还是有些复杂，具体看代码
 **/
