# --- GIAI ĐOẠN 1: Tự động tải thư viện và build file WAR bằng Maven ---
FROM maven:3.9-eclipse-temurin-21 AS build_stage
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# --- GIAI ĐOẠN 2: Đưa file WAR đã build sang Tomcat để chạy ---
FROM tomcat:11.0.22-jdk21
RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY --from=build_stage /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]