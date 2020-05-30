package com.webrtc.controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

@RestController
@RequestMapping("/")
public class testController {
    @GetMapping("index")
    public ModelAndView webBroadcast(ModelMap modelMap){
        return new ModelAndView("/index", modelMap);
    }
}
