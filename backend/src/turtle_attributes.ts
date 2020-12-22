export enum move {
  forward = "move forward ",
  back = "move back ",
  left = "move left ",
  right = "move right ",
  up = "move up ",
  down = "move down ",
}

export enum dig {
  forward = "dig forward ",
  up = "dig up ",
  down = "dig down ",
}

export enum tunnel {
  forward = "tunnel forward ",
  up = "tunnel up ",
  down = "tunnel down ",
}

export interface InventoryCell {
  count?: number;
  name?: string;
  damage?: number;
}

//todo make this actually nice
