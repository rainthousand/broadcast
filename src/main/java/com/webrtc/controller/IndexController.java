package com.webrtc.controller;

import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;



@RestController
@RequestMapping("/web")
public class IndexController {

    @GetMapping("webBroadcast")
    public ModelAndView webBroadcast(ModelMap modelMap){
        return new ModelAndView("/broadcast", modelMap);
    }

    @GetMapping("webWatch")
    public ModelAndView webWatch(ModelMap modelMap){
        return new ModelAndView("/watch", modelMap);
    }

}