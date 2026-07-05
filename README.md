# ContainerAgent

Локальный сервер на Vapor, который управляет Apple Container (github.com/apple/container)
через REST API. Идея: выбирать проект и запускать build/run/stop/logs для его контейнера
удалённо, не заходя в терминал Mac.

## Требования

- macOS с установленным Apple Container (`brew install container`, затем `container system start`)
- Swift 6.0+

## Конфигурация проектов

Список проектов задаётся в `Config/projects.json`:

```json
{
  "projects": [
    {
      "id": "example-api",
      "name": "Example API",
      "path": "/path/to/project",
      "containerfile": "Containerfile",
      "imageName": "example-api:latest",
      "env": { "GREETING": "hello" },
      "ports": ["127.0.0.1:8081:8081"],
      "volumes": ["/host/data:/data"]
    }
  ]
}
```

- `id` — используется в путях API
- `path` — рабочая директория, где лежит `Containerfile` (там же будет выполняться `container build`)
- `imageName` — тег образа, который получит сборка
- `env` (опционально) — переменные окружения контейнера, передаются как `-e key=value`
- `ports` (опционально) — проброс портов, передаётся как `-p <значение>` в `container run`.
  **Важно:** нужно указывать host-IP явно (`127.0.0.1:8081:8081`), формат без IP
  (`8081:8081`) в Apple Container 1.0 порт не публикует
- `volumes` (опционально) — bind-монтирование, передаётся как `-v host:container`

## Запуск

Обязательна переменная окружения `AGENT_TOKEN` — без неё сервер не стартует.

```
AGENT_TOKEN=<секрет> swift run
```

По умолчанию сервер слушает `0.0.0.0:8080`. Порт можно переопределить через `PORT`,
путь к конфигу проектов — через `PROJECTS_CONFIG`.

## Аутентификация

Все запросы требуют заголовок:

```
Authorization: Bearer <AGENT_TOKEN>
```

Без него сервер отвечает 401.

## API

| Метод | Путь                                  | Описание                              |
|-------|---------------------------------------|----------------------------------------|
| GET   | `/projects`                           | Список проектов из конфига             |
| POST  | `/projects/:projectID/build`          | Собрать образ проекта                  |
| POST  | `/projects/:projectID/run`            | Запустить контейнер из образа проекта (ответ содержит `containerName`) |
| GET   | `/projects/containers`                | Список всех контейнеров                |
| GET   | `/projects/containers/:name/logs`     | Логи контейнера                        |
| POST  | `/projects/containers/:name/stop`     | Остановить контейнер                   |

Пример:

```
curl -H "Authorization: Bearer <секрет>" http://127.0.0.1:8080/projects
```

## Что уже сделано

- Обёртка над CLI `container` (build/run/stop/logs/list) через `Process`
- Реестр проектов из JSON-конфига
- REST API поверх обёртки
- Bearer-токен аутентификация на все эндпоинты
- Проверено вручную: сборка проекта, авторизация, список контейнеров
- iOS-клиент (CIloopiOS, SwiftUI): список проектов, детали контейнера, действия build/run/stop, логи
- Клиент подключён к живому агенту (`LiveAgentClient`), проверено: реальные данные из `projects.json`
  вместо моков, ошибки сервера долетают до UI без падения приложения
- Локальный токен и адрес агента задаются через `Resources/AgentConfig.plist` (не коммитится,
  есть шаблон `AgentConfig.example.plist`)
- Поддержка `env`/`ports`/`volumes` в конфиге проекта — проверено: env-переменная и
  опубликованный порт долетают до реального контейнера через полный путь агент → API → приложение

## Что дальше

- Реальный проект с `Containerfile` для честной проверки build/run
- Удалённый доступ (не из локальной сети) через приватный туннель (например, Tailscale)
