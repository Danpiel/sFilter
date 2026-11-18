-- Localization. Keys are the English texts; missing translations fall back to the key.

local _, ns = ...

local L = setmetatable({}, {
	__index = function(_, key)
		return key
	end,
})
ns.L = L

L.ICONS_HELP = "Every icon watches one or more spells on a unit and is shown while one of them is active. "
	.. "Auras are matched by ID and by name, so one ID covers all ranks.\n\n"
	.. "The button next to a spell sets whose auras count: only yours (and your pet's) or anyone's. "
	.. "Several icons can share a slot: the one higher in the list wins."
L.GROUPS_HELP = "Unlock the groups (button at the top or /sf unlock) and drag them with the left mouse button. "
	.. "Right-click a group for a quick menu. A pinned group cannot be dragged by accident.\n\n"
	.. "X and Y are the offset of the group's starting corner from the center of the screen."
L.PROFILE_HELP = "Export creates a string you can share or keep as a backup. Paste a string into the box and press Import. "
	.. "\"Layout only\" moves and resizes your groups without touching your icons."
L.CDM_HELP = "In combat, in boss encounters, Mythic+ and PvP matches the game hides aura details from addons. "
	.. "Buffs on you and your pet and debuffs on your target and focus are still shown in combat: "
	.. "Blizzard's own aura container fills sFilter's icons.\n\n"
	.. "Other icons (debuffs on you, buffs on your target) work in combat only if the game's Cooldown Manager tracks the spell: "
	.. "enable it, open it (/cdm), drag the spells into \"Tracked Buffs\" and set them to \"Hide when inactive\" in Edit Mode."

if GetLocale() ~= "ruRU" then
	return
end

local R = {
	["%d icons"] = "иконок: %d",
	["Add icons from Tracked Buffs"] = "Добавить иконки из CDM",
	["Add these to Tracked Buffs in /cdm to see them in combat:"] = "Добавьте в «Отслеживаемые баффы» (/cdm), чтобы видеть их в бою:",
	["Add"] = "Добавить",
	["Added %d icons."] = "Добавлено иконок: %d.",
	["Aura type"] = "Тип ауры",
	["Buff"] = "Бафф",
	["Buffs"] = "Баффы",
	["Buffs and debuffs"] = "Баффы и дебаффы",
	["Debuffs on your target and buffs on you and your pet that matter for your rotation."] = "Нужные дебаффы на цели и баффы на себе и питомце, чтобы держать ротацию.",
	["Clear"] = "Очистить",
	["Combat and the Cooldown Manager"] = "Бой и Cooldown Manager",
	["Commands:"] = "Команды:",
	["Cooldown Manager is available"] = "Cooldown Manager доступен",
	["Cooldown Manager is enabled"] = "Cooldown Manager включён",
	["Cooldown Manager status"] = "состояние Cooldown Manager",
	["Cooldown Manager"] = "Cooldown Manager",
	["Copy the string with Ctrl+C."] = "Скопируйте строку через Ctrl+C.",
	["sFilter: moving icon groups"] = "sFilter: перемещение групп иконок",
	["Debuff"] = "Дебафф",
	["Defensives"] = "Защита",
	["Delete"] = "Удалить",
	["Delete group \"%s\"? Its icons move to the first group."] = "Удалить группу «%s»? Её иконки перейдут в первую группу.",
	["Delete icon \"%s\"?"] = "Удалить иконку «%s»?",
	["Disabled"] = "Выключена",
	["Down"] = "Вниз",
	["Drag to move."] = "Перетащите, чтобы переместить.",
	["Edit Mode: Tracked Buffs, \"Hide when inactive\""] = "Режим редактирования: Отслеживаемые баффы, «Скрывать неактивные»",
	["Edit Mode: Tracked Buffs, visibility \"Always\""] = "Режим редактирования: Отслеживаемые баффы, видимость «Всегда»",
	["Enable Cooldown Manager"] = "Включить Cooldown Manager",
	["Export / Import"] = "Экспорт / импорт",
	["Export everything"] = "Экспорт всего",
	["Export layout only"] = "Экспорт расположения",
	["Focus"] = "Фокус",
	["Grid"] = "Сетка",
	["Group settings..."] = "Настройки группы...",
	["Group"] = "Группа",
	["Groups and icons of this class will be replaced."] = "Группы и иконки этого класса будут заменены.",
	["Groups locked."] = "Группы закреплены.",
	["Groups"] = "Группы",
	["Grow direction"] = "Направление роста",
	["Hide group"] = "Скрыть группу",
	["Icon size"] = "Размер иконки",
	["Icons in one slot: the upper one wins."] = "Иконки в одном слоте: побеждает та, что выше в списке.",
	["Icons per row"] = "Иконок в ряду",
	["Icons shown through the Cooldown Manager: %d"] = "Иконок через Cooldown Manager: %d",
	["Icons"] = "Иконки",
	["Import sFilter settings?"] = "Импортировать настройки sFilter?",
	["Import everything"] = "Импорт всего",
	["Import failed:"] = "Ошибка импорта:",
	["Import layout only"] = "Импорт расположения",
	["Left click: settings"] = "Левый клик: настройки",
	["Left"] = "Влево",
	["Lock all groups"] = "Закрепить все группы",
	["Lock groups"] = "Закрепить группы",
	["Lock"] = "Закрепить",
	["Me"] = "На мне",
	["Mine"] = "Мои",
	["Anyone"] = "Все",
	["Whose auras count"] = "Чьи ауры считать",
	["Mine: cast by you or your pet."] = "Мои: наложенные вами или питомцем.",
	["Anyone: cast by anyone."] = "Все: наложенные кем угодно.",
	["Click to switch."] = "Нажмите, чтобы переключить.",
	["Movers unlocked: drag groups with the left mouse button, right-click for options."] = "Группы разблокированы: перетаскивайте левой кнопкой мыши, правый клик — меню.",
	["Name"] = "Название",
	["New group"] = "Новая группа",
	["New row goes"] = "Новый ряд",
	["Not available in the Cooldown Manager, shown out of combat only:"] = "Нет в Cooldown Manager, видны только вне боя:",
	["Only group positions and look will be replaced, your icons stay."] = "Будут заменены только положение и вид групп, ваши иконки останутся.",
	["Opacity, %"] = "Непрозрачность, %",
	["Open Cooldown Manager (/cdm)"] = "Открыть Cooldown Manager (/cdm)",
	["Open settings"] = "Открыть настройки",
	["Pet"] = "Питомец",
	["Pin this group (cannot be dragged)"] = "Закрепить группу (нельзя перетащить)",
	["Pin this group"] = "Закрепить группу",
	["Procs"] = "Проки",
	["Profile reset to defaults."] = "Профиль сброшен к стандартному.",
	["Profile:"] = "Профиль:",
	["Refresh"] = "Обновить",
	["Reset groups and icons of this class to the defaults?"] = "Сбросить группы и иконки этого класса к стандартным?",
	["Reset position"] = "Сбросить позицию",
	["Reset to defaults"] = "Сбросить к стандартным",
	["Right click: unlock / lock groups"] = "Правый клик: разблокировать / закрепить группы",
	["Right"] = "Вправо",
	["Right-click: menu."] = "Правый клик: меню.",
	["Select an icon on the left or add a new one."] = "Выберите иконку слева или добавьте новую.",
	["Settings imported."] = "Настройки импортированы.",
	["Settings"] = "Настройки",
	["Show inactive icons (dimmed)"] = "Показывать неактивные иконки (затемнёнными)",
	["Show inactive icons"] = "Показывать неактивные иконки",
	["Slot"] = "Слот",
	["Spacing"] = "Отступ",
	["Spell ID, link or name"] = "ID, ссылка или название заклинания",
	["Spell IDs, comma separated (first found is shown)"] = "ID заклинаний через запятую (показывается первое найденное)",
	["Spell not found:"] = "Заклинание не найдено:",
	["Target debuffs"] = "Дебаффы цели",
	["Target"] = "На цели",
	["The string does not contain sFilter settings."] = "Строка не содержит настроек sFilter.",
	["The string was made for another class (%s)."] = "Строка сделана для другого класса (%s).",
	["The string was made for another game version, some spells may not exist."] = "Строка сделана для другой версии игры, некоторых заклинаний может не быть.",
	["This client has no Cooldown Manager."] = "В этом клиенте нет Cooldown Manager.",
	["This group is pinned. Right-click to unpin it."] = "Группа закреплена. Правый клик, чтобы открепить.",
	["Unlock groups"] = "Разблокировать группы",
	["Up"] = "Вверх",
	["Whose auras"] = "Где искать ауру",
	["\"Hide when inactive\" is on"] = "«Скрывать неактивные» включено",
	["\"Tracked Buffs\" bar is visible"] = "Панель «Отслеживаемые баффы» видна",
	["combat"] = "бой",
	["in combat: readable"] = "в бою: доступна",
	["in combat: via Cooldown Manager"] = "в бою: через Cooldown Manager",
	["move or lock icon groups"] = "двигать или закрепить группы иконок",
	["no combat"] = "вне боя",
	["not found in this game version"] = "нет в этой версии игры",
	["open settings"] = "открыть настройки",
	["out of combat only"] = "только вне боя",
	["out of combat only: add it to Tracked Buffs in /cdm"] = "только вне боя: добавьте в «Отслеживаемые баффы» в /cdm",
	["pinned"] = "закреплена",
	["press the button below"] = "нажмите кнопку ниже",
	["reset the profile of this class"] = "сбросить профиль этого класса",
	["share settings"] = "поделиться настройками",

	ICONS_HELP = "Каждая иконка следит за одним или несколькими заклинаниями на выбранной цели и видна, пока одно из них активно. "
		.. "Ауры ищутся по ID и по названию, поэтому один ID покрывает все ранги.\n\n"
		.. "Кнопка рядом с заклинанием выбирает, чьи ауры считать: только ваши (и питомца) или любые. "
		.. "Несколько иконок могут занимать один слот: показывается та, что выше в списке.",
	GROUPS_HELP = "Разблокируйте группы (кнопка сверху или /sf unlock) и перетаскивайте их левой кнопкой мыши. "
		.. "Правый клик по группе открывает меню. Закреплённую группу нельзя сдвинуть случайно.\n\n"
		.. "X и Y — смещение начального угла группы от центра экрана.",
	PROFILE_HELP = "Экспорт создаёт строку, которой можно поделиться или сохранить как резервную копию. Вставьте строку в поле и нажмите «Импорт». "
		.. "«Расположение» двигает и меняет размер групп, не трогая ваши иконки.",
	CDM_HELP = "В бою, на боссах, в M+ и PvP-матчах игра скрывает от аддонов подробности аур. "
		.. "Баффы на вас и питомце и дебаффы на цели и фокусе всё равно видны в бою: "
		.. "иконки sFilter заполняет встроенный контейнер аур Blizzard.\n\n"
		.. "Остальные иконки (дебаффы на вас, баффы на цели) работают в бою, только если заклинание отслеживает Cooldown Manager: "
		.. "включите его, откройте (/cdm), перетащите заклинания в «Отслеживаемые баффы» и в режиме редактирования включите «Скрывать неактивные».",
	["works in combat"] = "работает в бою",
	["Fade out, sec"] = "Затухание, сек",
	["Show while the spell is on cooldown (ground effects)"] = "Показывать, пока идёт кулдаун (эффекты на земле)",
	["Flash when the timer runs out"] = "Вспышка по окончании таймера",
}

for key, value in pairs(R) do
	L[key] = value
end
