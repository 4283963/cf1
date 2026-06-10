package com.pet.transfer;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.pet.transfer.mapper")
public class PetTransferApplication {
    public static void main(String[] args) {
        SpringApplication.run(PetTransferApplication.class, args);
    }
}
