var t = current_time;//get_timer();

switch (stage) {
    case 0:
		var dir_z = -height/(2.*tan(fov/2.));//const
        while(pix<out_size) {// actual rendering loop
            var dir_x = (pix%width + 0.5) - width/2.;
            var dir_y = -(pix div width + 0.5) + height/2.;// this flips the image at the same time
            var vec = array(dir_x,dir_y,dir_z);
            var normalized = vec3_normalized(vec);
            var tmp = cast_ray(array(0,0,0), normalized);
            if (pix>=(cnt+1)*array_max) cnt++;
            framebuffer[cnt,pix-(cnt*array_max)] = tmp;
            pix++;
            if ( current_time - t > time_step ) return 0;
        }
        cnt = 0;
        pix = 0;
        stage++;
    break;

    case 1://unneccesary loops left in deliberately
        while(pix<out_size) {
            if (pix>=(cnt+1)*array_max) cnt++;
            var color = framebuffer[cnt,pix-(cnt*array_max)];
            var mx = max(1., max(color[0], max(color[1], color[2])));
            out[cnt,pix-(cnt*array_max)] = make_colour_rgb(255*color[0]/mx, 255*color[1]/mx, 255*color[2]/mx);
            pix++;
            if ( current_time - t > time_step ) return 0;
        }
        stage++;
        time_end = current_time - time_start;
        show_debug_message(time_end);
    break;
}
