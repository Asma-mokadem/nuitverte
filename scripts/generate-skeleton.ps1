$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding $false

function Write-Lf($relPath, $text) {
    $path = Join-Path $root $relPath
    New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force | Out-Null
    [System.IO.File]::WriteAllText($path, ($text -replace "`r`n", "`n"), $utf8)
    Write-Host "cree : $relPath"
}

$services = @(
    @{ Name = 'api-gateway';             Pkg = 'gateway';   Class = 'ApiGateway';            Gateway = $true  },
    @{ Name = 'customer-service';        Pkg = 'customer';  Class = 'CustomerService';       Gateway = $false },
    @{ Name = 'scheduler-service';       Pkg = 'scheduler'; Class = 'SchedulerService';      Gateway = $false },
    @{ Name = 'tariff-service';          Pkg = 'tariff';    Class = 'TariffService';         Gateway = $false },
    @{ Name = 'notification-service';    Pkg = 'notification'; Class = 'NotificationService'; Gateway = $false },
    @{ Name = 'charger-control-service'; Pkg = 'charger';   Class = 'ChargerControlService'; Gateway = $false },
    @{ Name = 'grid-quality-service';    Pkg = 'grid';      Class = 'GridQualityService';    Gateway = $false },
    @{ Name = 'utility-gateway-service'; Pkg = 'utility';   Class = 'UtilityGatewayService'; Gateway = $false },
    @{ Name = 'simulator';               Pkg = 'simulator'; Class = 'Simulator';             Gateway = $false }
)

$pomWeb = @'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.3.5</version>
    <relativePath/>
  </parent>

  <groupId>com.nuitverte</groupId>
  <artifactId>__NAME__</artifactId>
  <version>0.1.0</version>
  <name>__NAME__</name>

  <properties>
    <java.version>17</java.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <finalName>app</finalName>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
'@

$pomGateway = @'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.3.5</version>
    <relativePath/>
  </parent>

  <groupId>com.nuitverte</groupId>
  <artifactId>__NAME__</artifactId>
  <version>0.1.0</version>
  <name>__NAME__</name>

  <properties>
    <java.version>17</java.version>
    <spring-cloud.version>2023.0.3</spring-cloud.version>
  </properties>

  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-dependencies</artifactId>
        <version>${spring-cloud.version}</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>

  <dependencies>
    <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-gateway</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <finalName>app</finalName>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
'@

$app = @'
package com.nuitverte.__PKG__;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class __CLASS__Application {

    public static void main(String[] args) {
        SpringApplication.run(__CLASS__Application.class, args);
    }
}
'@

$test = @'
package com.nuitverte.__PKG__;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class __CLASS__ApplicationTests {

    @Test
    void contextLoads() {
    }
}
'@

$ymlWeb = @'
spring:
  application:
    name: __NAME__

server:
  port: 8080

management:
  endpoints:
    web:
      exposure:
        include: health,info
'@

$ymlGateway = @'
spring:
  application:
    name: api-gateway
  cloud:
    gateway:
      routes:
        - id: savings
          uri: "${TARIFF_URL:http://tariff-service:8080}"
          predicates:
            - Path=/api/v1/customers/*/savings
        - id: customers
          uri: "${CUSTOMER_URL:http://customer-service:8080}"
          predicates:
            - Path=/api/v1/customers/**,/api/v1/vehicles/**,/api/v1/devices/**
        - id: scheduler
          uri: "${SCHEDULER_URL:http://scheduler-service:8080}"
          predicates:
            - Path=/api/v1/charging-plans/**,/api/v1/sessions/**,/api/v1/zones/**
        - id: tariff
          uri: "${TARIFF_URL:http://tariff-service:8080}"
          predicates:
            - Path=/api/v1/tariffs/**
        - id: notification
          uri: "${NOTIFICATION_URL:http://notification-service:8080}"
          predicates:
            - Path=/api/v1/notifications/**

server:
  port: 8080

management:
  endpoints:
    web:
      exposure:
        include: health,info,gateway
  endpoint:
    gateway:
      enabled: true
'@

$dockerfile = @'
# Étape 1 : compilation (Maven + JDK 17)
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build/__NAME__
COPY __NAME__/pom.xml .
COPY contracts /build/contracts
COPY __NAME__/src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -B -q package -DskipTests

# Étape 2 : image finale légère (JRE alpine seulement)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=build /build/__NAME__/target/app.jar app.jar
USER app
EXPOSE 8080
ENV JAVA_OPTS="-Xmx256m"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
'@

foreach ($s in $services) {
    $n = $s.Name
    $pom = if ($s.Gateway) { $pomGateway } else { $pomWeb }
    $yml = if ($s.Gateway) { $ymlGateway } else { $ymlWeb }
    $base = "$n/src/main/java/com/nuitverte/$($s.Pkg)"
    $tbase = "$n/src/test/java/com/nuitverte/$($s.Pkg)"

    $rep = { param($t) $t.Replace('__NAME__', $n).Replace('__PKG__', $s.Pkg).Replace('__CLASS__', $s.Class) }

    Write-Lf "$n/pom.xml" (& $rep $pom)
    Write-Lf "$n/Dockerfile" (& $rep $dockerfile)
    Write-Lf "$n/src/main/resources/application.yml" (& $rep $yml)
    Write-Lf "$base/$($s.Class)Application.java" (& $rep $app)
    Write-Lf "$tbase/$($s.Class)ApplicationTests.java" (& $rep $test)
}
Write-Host "Termine : 9 squelettes generes."