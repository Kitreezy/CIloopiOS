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
      "imageName": "example-api:latest"
    }
  ]
}
```

- `id` — используется в путях API
- `path` — рабочая директория, где лежит `Containerfile` (там же будет выполняться `container build`)
- `imageName` — тег образа, который получит сборка

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
| POST  | `/projects/:projectID/run`            | Запустить контейнер из образа проекта  |
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

## Что дальше

- iOS-клиент (SwiftUI): список проектов и действия над контейнерами
- Удалённый доступ (не из локальной сети) через приватный туннель (например, Tailscale)
