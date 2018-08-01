# SealineInsurance

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sealine_insurance'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sealine_insurance

## Usage

Перед началом работы нужно создать клиента, задав необходимые настройки:

```ruby
client = SealineInsurance::Client.new(
  token: '0123456789abcdef',  # required
  host: 'sealine.ru',         # optional, default: dev.sealine.ru
  timeout: 10,                # optional
  open_timeout: 15,           # optional
  logger: Logger.new(...),    # optional
)
```

### 1. Запрос информации

Запрос типов продуктов:

```ruby
result = client.product_types
result.success?
# => true
result.body
# => {
#   "meta": {
#     ...
#   },
#   "objects": [
#     {
#       "id": 6,
#       "code": "transport",
#       "title": "НС пассажирских перевозок",
#       "details": "https://sealine.ru/api/v1/classifiers/product-type/6.json"
#     }
#   ]
# }
```

Аналогично можно запрашивать другую информацию:

```ruby
# списки статусов
client.calculate_status_list
client.order_status_list
client.payment_status_list

# продукты и их типы
client.product_types
client.product_type(id: 6)
client.products
client.search_products(product_type: 'transport')

# кастомные запросы информации
client.classifiers(path: 'product/vsk_trans')
client.classifiers(path: 'product/component-group')
```

### 2. Расчет стоимости страховки

Операция расчета асинхроная, в рамках одного расчета нужно выполнять несколько запросов к API. Эта логика инкапсулирована в класс операции.

Запуск расчета:

```ruby
operation = client.calculate(
  product_type: 'transport',
  products: %w[vsk_trans],
  ticket_price: Money.new(100, 'RUB'),
)
```

Проверка статуса операции:

```ruby
operation.finished?
# => false
```

Запрос актуального статуса:

```ruby
operation.fetch_status!
operation.finished?
# => true
```

Получение результата:

```ruby
operation.success?
# => true
operation.result.status
# => 'DONE'
operation.result.price
# => #<Money fractional:70 currency:RUB>
```

Или с ошибкой:

```ruby
operation.success?
# => false
operation.result.error_code
# => 'unauthorized'
operation.result.error_message
# => 'Недопустимый токен.'
```

### 3. Создание страховки

```ruby
operation = client.create_order(
  product_type: 'transport',
  product: 'vsk_trans',
  ticket_number: 12345678,
  ticket_price: Money.new(100, 'RUB'),
  departure_datetime: Time.new(2018, 8, 1, 10, 0, 0),
  arrival_datetime: Time.new(2018, 8, 1, 18, 0, 0),
  insured_first_name: 'Иван',
  insured_last_name: 'Иванов',
  insured_birthday: Date.new(1985, 1, 15),
  insurer_first_name: 'Петр',
  insurer_last_name: 'Петров',
)
```

Дальнейшие действия с `operation` аналогичны расчету стоимости.

### 4. Подтверждение страховки

```ruby
operation = client.create_payment(order_id: 7311)
```

Дальнейшие действия с `operation` аналогичны расчету стоимости.

### 5. Возврат страховки

```ruby
operation = client.cancel_order(order_id: 7311)
```

Дальнейшие действия с `operation` аналогичны расчету стоимости.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
