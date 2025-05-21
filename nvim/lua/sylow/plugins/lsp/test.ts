interface IUser {
	name: string;
}

class User implements IUser {
	private _name: string;

	constructor(name: string) {
		this._name = name;
	}

	public get name(): string {
		return this._name;
	}

	public set name(value: string) {
		if (!value || value.trim().length === 0) {
			throw new Error("Name cannot be empty.");
		}
		this._name = value;
	}
}

const user: IUser = new User("Ruben");
console.log(user.name);

interface IAnimal {
	name: string;
	talk: void;
}

