switch (stage) {
    case 0:
		draw_text(0,10, string(pix)+"/"+string(out_size));
	break;
	
    case 1:
        draw_text(0,10, string(out_size)+"/"+string(out_size));
    break;

    case 2:
        if (!surface_exists(surf)) {
            surf = surface_create(width,height);
            surface_set_target(surf);
            draw_clear_alpha(c_black, 0);
            var k = 0;
            for (var i=0; i<height; i++) {
                for (var j=0; j<width; j++) {
                    draw_point_colour(j,i, out[k]);
                    k++;
                }
            }
            surface_reset_target();
        }

        draw_surface(surf, 0, 0);
        draw_text(0,0, "your score is and always has been");
        draw_text(0,10, time_end);
    break;
}