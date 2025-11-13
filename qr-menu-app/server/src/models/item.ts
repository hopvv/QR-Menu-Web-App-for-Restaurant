export interface MenuItem {
	id: number;
	restaurantId: number;
	categoryId: number;
	name: string;
	description?: string;
	price: number;
	isAvailable: boolean;
	photoUrl?: string;
	dietaryInfo?: string;
	sortOrder: number;
	cacheVersion: number;
	createdAt: Date;
	updatedAt: Date;
}

export interface Item extends MenuItem {}
