# Інфопанель

Це та кнопочка в головному меню, де знаходиться різна інформація або посібники для наших гравців.

## Додавання документів

Контент додається доволі незручно. Треба редагувати цілих **три** файли.

Для початку, потрібно створити документ в `data/infopanel_docs/` з закінченням файлу `.md`,
так як інфопанель була спеціально написана для парсингу даних документів.
Проте, здібності Markdown в нашій версії дещо урізані. Про це йдеться далі.

### Як писати документ

Парсер Markdown в інфопанелі (PrMarkdown) не має всіх здібностей, які є в CommonMark (специфікація для стандартизації Markdown документів), проте, по
більшій частині, парсер зможе прочитати любий Markdown документ.

Які можливості не має PrMarkdown:

- **напівжирне виділення** (\*\*текст\*\*)
- *текст курсивом* (\*текст\*)
- `моноширинний текст` (\`текст\`)
- і всі інші типи виділення тексту. Більше можете дізнатись, заглянувши [сюди](../lua/prsbox/infopanel/cl_infopanel.lua).
Пролистайте до 26-ї строки або, інакше, до функції `PANEL:LoadDocument()`.

Пронумеровані списки працюють таким чином: якщо строка почитається на цифру,
вона стає елементом пронумерованого списку. Тобто, якщо ви в документі
напишете якось так:

```md
25 гравців - середній онлайн нашого крутого серверу.
```

Воно сприйметься парсером, як елемент пронумерованого списку, а тому, матиме відступи,
невластиві для стандартного тексту.

Не потрібно писати будь який спеціальний елемент без пробілів.
Ваш документ не те що наш парсер не зможе прочитати, його
не зможе прочитати навіть CommonMark-compliant парсер.

```md
#Приклад поганого документу

##Чому цей документ поганий:

-Він написаний таким чином
-Що парсер не зможе його прочитати

##Як зробити його адекватним
1.Відкрити "data/infopanel_docs/main.md"
2.Подивитись як воно написане
3.Писати нормальні документи!1!
```

Приклад ідеального PrMarkdown документу [ось](../data/infopanel_docs/main.md).

### Додаємо ваш документ до інфопанелі

Для того, щоб додати ваш документ до інфопанелі, вам потрібно його зареєструвати
в двох файлах: `/lua/infopanel/main.lua` та `/lua/infopanel/cl_infopanel.lua`.

#### main.lua

Візьміть назву вашого документу і внесіть таблицю `infopanel_docs`,
без розширення файлу (`.md`). Це все, що треба робити в цьому файлі.

Такі дії треба виконати, щоб документ завантажувався гравцю при підключенні
до сервера.

#### cl_infopanel.lua

```lua
do
    local PANEL = {}

    function PANEL:Init()
        self:LoadDocument("test")
    end

    vgui.Register("PRSBOX.Infopanel.TabContent.Test", PANEL, "PRSBOX.Infopanel.TabContent")
end
```

Скопіюйте даний блок і вставте десь нижче в файлі,
перед панеллю `tabMenu`. В функції `PANEL:Init()` відредагуйте
`self:LoadDocument()`. Вставте в дужки назву вашого документа.
Перейдіть в кінець блоку, до `vgui.Register(...)`.
Замініть `"PRSBOX.Infopanel.TabContent.Test"` на
`"PRSBOX.Infopanel.TabContent.YourDoc"`,де `YourDoc` - назва вашого документу в стилі
CamelCase.

Тепер до `tabMenu`. Знайдіть місце, де знаходяться строки `tabMenu:AddTab(...)`.
Додайте в наступну строку таку ж саму функцію.
В дужках, першим аргументом вставте заголовок для вкладки,
а другим аргументом - той текст, який ви вказували в `vgui.Register()`.
Функція повинна виглядати приблизно так:

```lua
    ...
    tabMenu:AddTab("Тест", "PRSBOX.Infopanel.TabContent.Test")
    ...
```

Це треба робити, щоб документ почав відображатись в самій інфопанелі.

На цьому реєстрація документа завершена. Вітаю!