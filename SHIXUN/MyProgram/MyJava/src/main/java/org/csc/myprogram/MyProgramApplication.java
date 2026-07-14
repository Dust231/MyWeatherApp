package org.csc.myprogram;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

// Spring Boot 启动类核心注解，缺一不可
@SpringBootApplication
public class MyProgramApplication {
    // Java 程序固定入口方法
    public static void main(String[] args) {
        // 启动 Spring Boot 项目的核心语句
        SpringApplication.run(MyProgramApplication.class, args);
    }
}