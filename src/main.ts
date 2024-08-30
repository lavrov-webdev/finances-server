import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import { ValidationPipe } from "@nestjs/common";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = new DocumentBuilder()
    .setTitle("Finances app")
    .setDescription("App for managing your personal finances")
    .setVersion("1.0")
    .addCookieAuth("access_token")
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup("api/docs", app, document);
  app.useGlobalPipes(new ValidationPipe({ transform: true }));
  console.log()
  app.enableCors({
    origin: process.env.DEV === "true" ? true : "https://bbabrjced7868pqsc83u.containers.yandexcloud.net",
    credentials: true,
  });
  await app.listen(process.env.PORT);
}
bootstrap();
